{ config, lib, pkgs, ... }:

let
  #unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz; #Dodaj repozytorium Bleeding Edge
in
{
  imports =
    [ # Inne configi do zaimportowania
      ./hardware-configuration.nix
      ./zerotier.nix
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
    ];
  };

  # Automatyczne czyszczenie staroci
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d"; # Usuwaj generacje starsze niż 14 dni
    };
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

  # Konto użytkownika.
  users.users.rabbit = {
    isNormalUser = true;
    description = "rabbit";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    #packages = with pkgs; [ # Programy tylko dla użytkownika
    #  kdePackages.kate
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
    settings.default = ["kitty.desktop"]; # Ustaw kitty jako domyślny terminal
  };

  # Wbudowane w nixos moduły programów i ich opcje. Programy użytkowe są w programs.nix
  programs = {

    cdemu = {  # Włącz wsparcie płyt i ich montowania
      enable = true;
      gui = false;
      group = "wheel";
    };

    nix-ld = { #Tutaj można dodać brakujące biblioteki dla aplikacji które pobraliśmy z sieci
      enable = true;
      #libraries = with pkgs; [
      #
      #];
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
        nup = "tldr --update && sudo nix-channel --update && sudo nixos-rebuild boot --upgrade";
        nlive = "tldr --update && sudo nix-channel --update && sudo nixos-rebuild switch --upgrade";
        nref = "sudo nix-channel --update";
        pbot = "/home/rabbit/Dokumenty/STREAM/PhantomBot/launch.sh";
        kitty-themes = "kitty +kitten themes";
        errors = "journalctl -p 3";
        kimsufi = "kitty +kitten ssh debian@54.38.195.168";
        zero="sudo zerotier-cli";
        zero-fix="sudo route add -host 255.255.255.255 dev ztks575eoa && route -n && sudo zerotier-cli status";
      };
      histSize = 30000;              # Rozmiar historii
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

  # Wersja systemu. By dokonać dużej aktualizacji, zmień stateVersion a następnie wpisz w terminal. 
  # Zmiana stateVersion spowoduje że config może być niekompatybilny z nową wersją i będzie wymagać manualnej interwencji.
  # Możesz też zmienić tylko kanał a zostawić stateVersion, ale to może powodować błędy na dłuższą metę.
  # sudo nix-channel --add https://channels.nixos.org/nixos-25.05 nixos
  system.stateVersion = "25.05";
}
