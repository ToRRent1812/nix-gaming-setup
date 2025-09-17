{ config, lib, pkgs, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Inne configi
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

  # Dodaj opcjonalne repo Bleeding Edge. By zainstalować program, przed nazwą dopisz unstable. by zainstalować z NUR, dodaj nur.repos.
  nixpkgs.config = {
    allowUnfree = true; # Programy nie-wolnościowe
    packageOverrides = pkgs:
    {
      unstable = import unstableTarball { config = config.nixpkgs.config; };
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") { inherit pkgs; };
    };
    permittedInsecurePackages = [ # Któryś program, chyba rustdesk tego wymaga
      "openssl-1.1.1w"
    ];
  };

  # Automatyczne czyszczenie staroci
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" ];
    };
  };

    # Zmienne środowiskowe
  environment.sessionVariables = {
    EDITOR = "nano";
    GTK_USE_PORTAL = 1;
    OBS_VKCAPTURE_QUIET = 1;
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
  users.defaultUserShell = pkgs.zsh; # Ustaw zsh domyślnie dla wszystkich
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
    settings.default = ["kitty.desktop"];
  };

  # Wbudowane w nixos moduły programów i ich opcje. Programy użytkowe są w programs.nix
  programs = {

    cdemu = {  # Włącz wsparcie płyt i ich montowania
      enable = true;
      gui = false;
      group = "wheel";
    };

    nix-ld = { #Tutaj można dodać brakujące biblioteki dla aplikacji które pobraliśmy z sieci, np. TheXTech
      enable = true;
      libraries = with pkgs; [

      ];
    };

    appimage.enable = true; # Włącz wsparcie AppImage
    java.enable = true; # Włącz wsparcie java
    npm.enable = true; # Włącz wsparcie npm dla Hugo
    virt-manager.enable = true; # Dodaj virt manager
    dconf.enable = true;

    zsh = {
      enable = true; # Włącz zsh w konsoli
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableLsColors = true;
      shellAliases = { #aliasy komend
        apply-config = "cd /home/rabbit/github/nix/nix-gaming-setup/ && sudo cp configuration.nix hardware-configuration.nix zerotier.nix /etc/nixos/ && sudo nixos-rebuild switch";
        system-update = "tldr --update && sudo nix-channel --update && sudo nixos-rebuild boot --upgrade";
        live-update = "tldr --update && sudo nix-channel --update && sudo nixos-rebuild switch --upgrade";
        nix-refresh = "sudo nix-channel --update";
        pbot = "cd /mnt/share/STREAM/PhantomBot && ./launch.sh";
        kitty-themes = "kitty +kitten themes";
        errors = "journalctl -p 3";
        zero="sudo zerotier-cli";
        zero-fix="sudo route add -host 255.255.255.255 dev ztks575eoa && route -n && sudo zerotier-cli status";
      };
      histSize = 30000;
      ohMyZsh = { # Włącz i ustaw oh-my-zsh
        enable = true;
        plugins = [ "git" "command-not-found" "" ];
        theme = "fox";
      };
    };

    git = { # Włącz wsparcie git
      enable = true;
      package = pkgs.gitFull;
      #config.credential.helper = "libsecret";
    };
  };

  # Włącz keyring dla github-desktop
  #services.gnome.gnome-keyring.enable = true;
  #security.pam.services.sddm.enableGnomeKeyring = true;

  # Wersja systemu. By dokonać dużej aktualizacji, zmień stateVersion a następnie wpisz w terminal
  # sudo nix-channel --add https://channels.nixos.org/nixos-25.05 nixos
  system.stateVersion = "25.05";
}
