{ config, lib, pkgs, ... }:
{
  imports =
    [ # Inne configi do zaimportowania
      ./hardware-configuration.nix
      ./services.nix
      ./vr.nix
      ./programs.nix
      ./boot.nix
      ./hardware.nix
      ./audio.nix
      ./locale.nix
      ./network.nix
    ];

  # Dodaj opcjonalne repozytoria. By zainstalować program, przed nazwą dopisz unstable. by zainstalować z NUR, dodaj nur.repos.
  nixpkgs.config = {
    allowUnfree = true;         # Programy nie-wolnościowe (steam, discord, itp)
    packageOverrides = pkgs:
    {
      nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") { inherit pkgs; };
      #unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-unstable.zip") { config = config.nixpkgs.config; };
      stable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.11.tar.gz") { config = config.nixpkgs.config; };
      pinnedkernel = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f32b0250a690c5aceb0fbe033c896a1a1bc7ca70.tar.gz") { config = config.nixpkgs.config; };
    };
    permittedInsecurePackages = [ 
      "openssl-1.1.1w"          # sublime wymaga
    ];
  };

  # Tymczasowo lutris wymaga
  nixpkgs.overlays = [
    (_: prev: {
      openldap = prev.openldap.overrideAttrs {
        doCheck = !prev.stdenv.hostPlatform.isi686;
      };
    })
  ];

  # Automatyczne czyszczenie staroci
  nix = {
    #gc = {
    #  automatic = true;
    #  dates = "daily";
    #  options = "--delete-older-than 14d"; # Usuwaj generacje starsze niż 14 dni
    #};
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" ];
    };
  };

  # Zmienne środowiskowe
  environment.sessionVariables = {
    EDITOR = "nano";                       # Domyślny edytor tekstu w terminalu
    GTK_USE_PORTAL = 1;                    # Wymuś użycie portali XDG w programach GTK, by np. program używał systemowego file pickera
    OBS_VKCAPTURE_QUIET = 1;               # Wyłącz zbędne logi z vk capture do OBS Studio
  };

  security.sudo.wheelNeedsPassword = false; # Użytkownicy w grupie wheel nie muszą pisać hasła do sudo

  # Konto użytkownika. Zmień rabbit na własny nick podany w instalacji. Zmień rabbit również w pliku services.nix, zakładka Displaymanager
  users.users.rabbit = {
    isNormalUser = true;
    description = "rabbit";
    extraGroups = [ "networkmanager" "wheel" "docker" "users" ];
    #packages = with pkgs; [ # Programy tylko dla użytkownika
    #];
  };
  users.defaultUserShell = pkgs.zsh;        # Ustaw zsh domyślnie dla wszystkich
  users.groups.libvirtd.members = ["rabbit"]; # Dodaj mnie do wirtualizacji

  # Włącz wsparcie Flatpak, portal XDG oraz dodaj Flathub
  services.flatpak.enable = true;
  fonts.fontDir.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && flatpak --user override --filesystem=host
    '';
  };

  # Aktywuj portale XDG
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = ["kitty.desktop"]; # Ustaw konsole jako domyślny terminal
  };

  # Wbudowane w nixos moduły programów i ich opcje. Programy użytkowe są w programs.nix
  programs = {

    cdemu = {  # Włącz wsparcie płyt i ich montowania
      enable = true;
      gui = true;
      group = "wheel";
    };

    nix-ld.enable = true; # Pozwala ładować statyczne bibloteki. Użyteczne jak ściągasz gotowe linuxowe gry i programy.

    nh = { #Rozszerzenie komend nixos
      enable = true;
    };

    appimage.enable = true;           # Włącz wsparcie AppImage
    appimage.binfmt = true; 
    java.enable = true;               # Włącz wsparcie java
    npm.enable = true;                # Włącz wsparcie npm dla Hugo
    virt-manager.enable = true;       # Dodaj virt manager
    dconf.enable = true;              # Włącz dconf by działały niektóre programy gnome

    zsh = {
      enable = true;                  # Włącz zsh w konsoli
      enableCompletion = true;        # Włącz autouzupełnianie
      autosuggestions.enable = true;  # Włącz podpowiedzi w stylu fish
      syntaxHighlighting.enable = true; # Włącz podświetlanie składni
      enableLsColors = true;          # Włącz kolory w ls
      shellAliases = {                # Aliasy komend
        nix-switch = "nh os switch -f '<nixpkgs/nixos>'";  # nowa generacja systemu na żywo
        nix-boot = "nh os boot -f '<nixpkgs/nixos>'";      # nowa generacja systemu po restarcie
        nix-ref = "sudo nix-channel --update -v";  # odświeżenie kanałów nixos
        nix-rep = "sudo nix-channel --repair";     # naprawienie kanałów nixos
        nix-up = "tldr --update && flatpak update -y && sudo journalctl --vacuum-time=2d && nix-ref && nix-boot && nh clean all --keep 4"; # aktualizacja systemu po restarcie
        nix-live = "tldr --update && flatpak update -y && sudo journalctl --vacuum-time=2d && nix-ref && nix-switch && nh clean all --keep 4"; # aktualizacja systemu na żywo
        pbot = "/home/rabbit/Dokumenty/STREAM/PhantomBot/launch.sh"; # uruchomienie bota do streamu
        errors = "sudo journalctl --vacuum-time=2d && journalctl -p 3"; # pokaż błędy z dziennika systemowego
        zero = "sudo zerotier-cli";             # skrót do zarządzania ZeroTier
        zero-fix = "sudo route add -host 255.255.255.255 dev ztks575eoa && route -n && sudo zerotier-cli status"; # naprawa server browser LAN w grach
        rabbisnaz="cd /home/rabbit/Dokumenty/Github/snaz-like/ && nix-shell --run 'python3 main.py' shell.nix";
        rbot="cd /home/rabbit/Dokumenty/Github/rabbibot/ && nix-shell --run 'python3 main.py' shell.nix";
        algorytm="cd /home/rabbit/Dokumenty/Github/powaznaliga-algorytm/ && nix-shell --run 'python3 main.py' shell.nix";
        lowercase="find . -depth | while read -r f; do mv \"$f\" \"\$(dirname \"$f\")/\$(basename \"$f\" | tr 'A-Z' 'a-z')\"; done";
      };
      histSize = 30000; # Rozmiar historii
      ohMyZsh = { # Włącz i ustaw oh-my-zsh
        enable = true;
        plugins = [ "git" "command-not-found" ];
        theme = "fox";
      };
    };

    git = { # Włącz wsparcie git
      enable = true;
      package = pkgs.gitFull;
      #config.credential.helper = "libsecret";
    };
  };

  # Wersja na której zainstalowałeś nixos.
  # By dokonać dużej aktualizacji, wpisz w terminal.
  # sudo nix-channel --add https://channels.nixos.org/nixos-25.11 nixos
  # 25.11 zastąp nową wersją
  # Zmiana stateVersion poniżej spowoduje że config może być niekompatybilny i będzie wymagać manualnej interwencji.
  # Nie musisz zmieniać stateVersion by zaktualizować Nixos!
  # Jeżeli będziesz po latach instalować NixOS z tym configiem, to pamiętaj by zmienić stateVersion zgodnie z wersją iso której użyłeś
  system.stateVersion = "25.05";
}
