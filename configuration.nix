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
      unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") { config = config.nixpkgs.config; };
      nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") { inherit pkgs; };
    };
    permittedInsecurePackages = [ 
      "openssl-1.1.1w"          # Któryś program, chyba rustdesk tego tymczasowo wymaga
      "mbedtls-2.28.10"
    ];
  };

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

  # Konto użytkownika. Zmień rabbit na własny nick podany w instalacji. Zmień rabbit również w pliku services.nix, zakładka Displaymanager
  users.users.rabbit = {
    isNormalUser = true;
    description = "rabbit";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    #packages = with pkgs; [ # Programy tylko dla użytkownika
    #];
  };
  users.defaultUserShell = pkgs.zsh;        # Ustaw zsh domyślnie dla wszystkich
  users.groups.libvirtd.members = ["rabbit"]; # Dodaj mnie do wirtualizacji

  # Włącz wsparcie Flatpak, portal XDG oraz dodaj Flathub
  /*services.flatpak.enable = true;
  fonts.fontDir.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && flatpak --user override --filesystem=host
    '';
  };*/

  # Aktywuj portale XDG
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = ["konsole.desktop"]; # Ustaw konsole jako domyślny terminal
  };

  # Wbudowane w nixos moduły programów i ich opcje. Programy użytkowe są w programs.nix
  programs = {

    cdemu = {  # Włącz wsparcie płyt i ich montowania
      enable = true;
      gui = true;
      group = "wheel";
    };

    nix-ld.enable = true; # Pozwala ładować statyczne bibloteki. Użyteczne jak ściągasz gotowe linuxowe gry i programy.
    nix-ld.libraries = with pkgs; [
    ];

    nh = { #Rozszerzenie komend nixos
      enable = true;
      clean.enable = true; # Włącz automatyczne czyszczenie
      clean.extraArgs = "--keep 5"; # Utrzymaj ostanie 5 generacji na dysku
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
        nswitch = "tldr --update && sudo journalctl --vacuum-time=7d && nh os switch -a -f '<nixpkgs/nixos>'";  # nowa generacja systemu na żywo
        nboot = "tldr --update && sudo journalctl --vacuum-time=7d && nh os boot -a -f '<nixpkgs/nixos>'";      # nowa generacja systemu po restarcie
        nref = "sudo nix-channel --update -v";  # odświeżenie kanałów nixos
        nrep = "sudo nix-channel --repair";     # naprawienie kanałów nixos
        ntest = "nix-shell -p";                 # testowanie pakietów w izolowanym środowisku
        nup = "tldr --update && sudo journalctl --vacuum-time=7d && nref && nboot"; # aktualizacja systemu po restarcie
        nlive = "tldr --update && sudo journalctl --vacuum-time=7d && nref && nswitch"; # aktualizacja systemu na żywo
        game = "sudo /run/current-system/sw/bin/sh -c 'echo high > /sys/class/drm/card1/device/power_dpm_force_performance_level'"; # włącz tryb wysokiej wydajności grafiki przed graniem. Robi to samo co gamemode
        pbot = "/home/rabbit/Dokumenty/STREAM/PhantomBot/launch.sh"; # uruchomienie bota do streamu
        errors = "sudo journalctl --vacuum-time=7d && journalctl -p 3"; # pokaż błędy z dziennika systemowego
        kimsufi = "ssh debian@54.38.195.168";   # połączenie z serwerem
        zero = "sudo zerotier-cli";             # skrót do zarządzania ZeroTier
        zero-fix = "sudo route add -host 255.255.255.255 dev ztks575eoa && route -n && sudo zerotier-cli status"; # naprawa server browser LAN w grach
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

  # Wersja startowa systemu. By dokonać dużej aktualizacji, wpisz w terminal.
  # sudo nix-channel --add https://channels.nixos.org/nixos-25.05 nixos
  # Zmiana stateVersion spowoduje że config może być niekompatybilny z nową wersją i będzie wymagać manualnej interwencji. Nie musisz zmieniać stateVersion by zaktualizować Nixos.
  # Jeżeli będziesz po latach instalować NixOS z tym configiem, to koniecznie użyj iso z tą samą wersją jako start.
  system.stateVersion = "25.05";
}
