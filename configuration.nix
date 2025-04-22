{ config, lib, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Inne configi
      ./hardware-configuration.nix
    ];

  # Dodaj opcjonalne repo Bleeding Edge. By zainstalować program, przed nazwą dopisz unstable.
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # Automatyczne czyszczenie garbo
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # Jądro systemu i jego moduły
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModulePackages = with config.boot.kernelPackages; [ xpadneo xone vhba v4l2loopback ];

  # Aktywacja sterowników
  hardware.xpadneo.enable = true; # Włącz sterownik do xpadów
  hardware.xone.enable = true; # Włącz sterownik xone
  programs.obs-studio.enableVirtualCamera = true; # Włącz wirtualną kamerę dla obs-studio

  # Włącz wsparcie płyt
  programs.cdemu.enable = true;
  programs.cdemu.group = "wheel";

  networking.hostName = "nixos"; # Nazwa hosta
  # networking.wireless.enable = true;  # WIFI

  # Proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Włącz internet
  networking.networkmanager.enable = true;

  # Strefa czasowa
  time.timeZone = "Europe/Warsaw";

  # Język
  i18n.defaultLocale = "pl_PL.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Włącz X11. Wyłącz by zostawić tylko Wayland
  services.xserver.enable = false;

  # KDE Plazma
  services.displayManager.sddm.enable = true; # login manager
  services.desktopManager.plasma6.enable = true; # Plasma6

  # Klawiatura w X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  console.keyMap = "pl2";

  # Wsparcie drukarek
  services.printing.enable = false;

  # Pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = false;
  };

  # Grafika
  hardware = {
    graphics = {
        enable = true;
        enable32Bit = true;
    };
  };

  # Nvidia
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta; // Kanał Beta/New-Feature
  #services.xserver.videoDrivers = ["nvidia"];
  #hardware.nvidia = {
    #modesetting.enable = true;
    #open = false;
    #nvidiaSettings = true;
  #};


  # Touchpad
  # services.xserver.libinput.enable = true;

  # Konto użytkownika.
  users.users.rabbit = {
    isNormalUser = true;
    description = "Rabbit";
    extraGroups = [ "networkmanager" "wheel" ];
    #packages = with pkgs; [ # Programy tylko dla użytkownika
    #  kdePackages.kate
    #];
  };
  # Automatyczne logowanie
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "rabbit";

  # Firefox
  programs.firefox.enable = false;

  # Programy nie-wolnościowe
  nixpkgs.config.allowUnfree = true;

  # Programy zainstalowane dla wszystkich użytkowników
  environment.systemPackages = with pkgs; [
  # System
  floorp
  kitty
  gitFull
  gitkraken
  zsh
  oh-my-zsh
  cdemu-daemon
  cdemu-client
  adwaita-icon-theme
  distrobox # Żeby mieć Faugus launcher
  onlyoffice-desktopeditors
  upscaler
  # KDE Plazma
  kdePackages.kdenlive
  # Gaming tools
  mangohud
  unstable.protonup-qt
  unstable.wineWowPackages.staging # Wine-staging
  winetricks
  unstable.umu-launcher
  unstable.lutris
  # Twitch/Youtube
  cameractrls
  chatterino2
  obs-studio
  # Gry
  unstable.vcmi
  fheroes2
  # Komunikacja
  discord
  (discord.override { withOpenASAR = true; withVencord = true; })
  discord-rpc # Rich presence
  caprine
  ];

  # Włącz keyring dla github-desktop
  #services.gnome.gnome-keyring.enable = true;
  #security.pam.services.sddm.enableGnomeKeyring = true;

  # Włącz Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Włącz java
  programs.java.enable = true;
  #programs.steam.package = pkgs.steam.override { withJava = true; };

  # Włącz git
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    #config.credential.helper = "libsecret";
  };


  programs.zsh = {
  enable = true; # Włącz zsh
  enableCompletion = true;
  autosuggestions.enable = true;
  syntaxHighlighting.enable = true;
  enableLsColors = true;
  shellAliases = {
    update-config = "sudo nixos-rebuild";
    upd = "sudo nixos-rebuild switch --upgrade";
    refresh = "sudo nix-channel --update";
    };
  histSize = 3000;
  ohMyZsh = { # Włącz i ustaw oh-my-zsh
    enable = true;
    plugins = [ "git" ];
    theme = "fox";
    };
  };
  users.defaultUserShell = pkgs.zsh; # Ustaw zsh domyślnie dla wszystkich

  # Otwórz porty lub zablokuj zaporę sieciową
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Wersja na której zainstalowałeś system
  # (man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
}
