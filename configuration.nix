{ config, lib, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable-small.tar.gz;
in
{
  imports =
    [ # Inne configi
      ./hardware-configuration.nix
      ./zerotier.nix
    ];

  # Dodaj opcjonalne repo Bleeding Edge. By zainstalować program, przed nazwą dopisz unstable.
  nixpkgs.config = {
    allowUnfree = true; # Programy nie-wolnościowe
    packageOverrides = pkgs:
    {
      unstable = import unstableTarball { config = config.nixpkgs.config; };
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
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" ];
    };
  };

  # Bootloader
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/vda";
      useOSProber = true; # Dodaj Windows do bootloadera
    };
    kernelPackages = pkgs.linuxPackages_zen; # Jądro systemu zen dla graczy
    extraModulePackages = with config.boot.kernelPackages; [ vhba ]; # Dodatkowe moduły/sterowniki jądra których nie ma niżej
    kernelParams = [ "mitigations=off" ];
    kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0; #Wyłącza split_lock, rekomendowane do gier
      "vm.max_map_count" = 2147483642; #Jak w SteamOS, niemal maksymalny możliwy map_count
    };
  };

# Szybsze zamykanie systemu
systemd.extraConfig = ''
  DefaultTimeoutStopSec=15s
'';

  # Optymalizacja RAM
  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

    # Zmienne środowiskowe
  environment.sessionVariables = {
    EDITOR = "nano";
    GTK_USE_PORTAL = 1;
    OBS_VKCAPTURE_QUIET = 1;
  };

  # Sprzęt
  hardware = {
    xpadneo.enable = true; # Włącz sterownik xinput
    #xone.enable = true; # Włącz wsparcie xboxowego dongla usb
    steam-hardware.enable = true;

    graphics = {
        enable = true; # Aktywuj akcelerację w aplikacjach 64 bitowych
        enable32Bit = true; # Aktywuj akcelerację w aplikacjach 32 bitowych
    };

    bluetooth = { # Ja nie mam bluetooth, to po co włączać
      enable = false;
      powerOnBoot = true;
    };
  };

    # Nvidia
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta; // Kanał Beta/New-Feature
  #services.xserver.videoDrivers = ["nvidia"];
  #hardware.nvidia = {
    #modesetting.enable = true;
    #open = true;
    #nvidiaSettings = true;
  #};

  # Profil zasilania CPU
  powerManagement = {
        enable = true;
        powertop.enable = true;
        cpuFreqGovernor = "performance"; #power, performance, ondemand
  };

  # Wysoka wydajność AMD GPU
  systemd.user.services.highgpu = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "AMD GPU set to High";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/bash -c 'echo high > /sys/class/drm/card1/device/power_dpm_force_performance_level'";
    };
  };

  # Aktywuj wirtualizację dla virt managera
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker.enable = false;
  };

  # Ustawienia sieciowe
  networking = {
    hostName = "nixos"; # Nazwa hosta
    networkmanager.enable = true; # Włącz internet
    wireless.enable = false;  # Włącz WIFI
    firewall.enable = false; # Zapora sieciowa
    nameservers = [ "1.1.1.1" "1.0.0.1" ]; # Cloudflare DNS
  };

  # Strefa czasowa
  time = {
    timeZone = "Europe/Warsaw";
    hardwareClockInLocalTime = true;
  };

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

  # Usługi
  services = {
    fwupd.enable = true; # Włącz wsparcie aktualizatora firmware
    xserver.enable = false; # Włącz X11. Wyłącz by zostawić tylko Wayland
    pulseaudio.enable = false; # Systemowy pulseaudio

    xserver.xkb = { # Polska klawiatura
      layout = "pl";
      variant = "";
    };

    displayManager = {
      sddm.enable = true; # Plasma login manager
      sddm.wayland.enable = true; # Włącz SDDM w trybie Wayland
      autoLogin.user = "rabbit";
      autoLogin.enable = true;
      defaultSession = "plasma"; # Plasma-wayland jako default

    };
    desktopManager.plasma6.enable = true; # Plasma 6

    printing.enable = false; # Wsparcie drukarek

    pipewire = { # Włącz pipewire
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = false; # Emulacja Pulseaudio
      extraConfig.pipewire."92-low-latency" = { # RT audio
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 32;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 32;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "32/48000";
            pulse.default.req = "32/48000";
            pulse.max.req = "32/48000";
            pulse.min.quantum = "32/48000";
            pulse.max.quantum = "32/48000";
          };
        }
        ];
        stream.properties = {
          node.latency = "32/48000";
          resample.quality = 10;
        };
      };
    };

    libinput.enable = false; # Wsparcie touchpadów
  };
  console.keyMap = "pl2"; # Polska klawiatura

  # Zezwól na audio w priorytecie realtime
  security.rtkit.enable = true;

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

  # Programy zainstalowane dla wszystkich użytkowników, które nie posiadają modułów wbudowanych w nix (sekcja programs)
  environment.systemPackages = with pkgs; [
  # System
  #(ffmpeg-full.override { withUnfree = true; withOpengl = true; })       # Kodeki multimedialne
  floorp            # Przeglądarka moja
  kitty             # Ulubiony terminal
  gitkraken         # GUI dla git
  sublime4          # Najlepszy edytor tekstu
  adwaita-icon-theme # Ikony dla aplikacji GTK4
  #distrobox         # Żeby mieć Faugus launcher
  #boxbuddy          # GUI dla distrobox
  hugo              # Strona internetowa
  onlyoffice-desktopeditors # Pakiet biurowy
  upscaler          # Upscale zdjęć
  qbittorrent       # Torrenty czasem się przydają
  rustdesk-flutter # Zdalny pulpit
  qdirstat          # Analiza danych
  nettools          # narzędzia sieciowe
  tealdeer          # tldr w konsoli
  fastfetch
  # KDE Plazma
  kdePackages.flatpak-kcm # Uprawnienia flatpak KDE
  kdePackages.discover # Odkrywca
  kdePackages.kdenlive # Do montażu
  avidemux          # Przycinanie filmów
  haruna            # Oglądanie filmów
  #unstable.klassy-qt6 # Motyw Klassy, obecnie nie kompatybilne
  papirus-icon-theme # Pakiet ikon
  darkly
  # Gaming tools
  mangohud          # FPSY, temperatury
  protonup-qt
  wineWowPackages.stable # Wine-stable
  winetricks
  unstable.umu-launcher # środowisko UMU do gier spoza steam
  unstable.lutris   # Najnowszy lutris
  #unstable.heroic   # Najnowszy Heroic Games Launcher
  adwsteamgtk       # Upiększ steam
  #unstable.faugus-launcher #Najnowszy Faugusik
  # Twitch/Youtube
  cameractrls       # Zarządzanie kamerą
  chatterino2       # Czytam chat
  audacious         # Muzyka
  audacious-plugins # Pluginy
  easyeffects       # Efekty mikrofonu
  scrcpy            # Przechwyć wideo z telefonu
  sqlitebrowser     # Przeglądaj bazę sqlite
  # Gry
  unstable.vcmi
  fheroes2
#Emulacja
  rpcs3
  pcsx2-bin
  shadps4
  ppsspp-qt
  # Komunikacja
  (discord.override { withOpenASAR = true; withVencord = true; })
  discord-rpc       # Rich presence
  caprine           # Messenger
  teamspeak3        # TS3
  ];

environment.plasma6.excludePackages = with pkgs.kdePackages; [ #Usuwanie zbędnych aplikacji domyślnych z plazmy
  kdepim-runtime
  elisa
];

  # Wbudowane w nixos moduły programów i ich opcje
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

    kdeconnect.enable = true; # KDE Connect
    firefox.enable = false; # Wyłącz Instalację Firefox
    thunderbird.enable = true; # Aktywuj mozilla thunderbird
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
        system-up = "tldr --update && flatpak update -y && sudo nix-channel --update && sudo nixos-rebuild boot --upgrade";
        live-up = "tldr --update && flatpak update -y && sudo nix-channel --update && sudo nixos-rebuild switch --upgrade";
        repo-refresh = "sudo nix-channel --update";
        pbot = "cd /mnt/share/STREAM/PhantomBot && ./launch.sh";
        split = "wine /home/rabbit/LiveSplit_1.6.9/LiveSplit.exe & sleep 10s && cd /home/rabbit/LiveSplit_1.6.9/amid\ evil-linux && ./AELAS";
        kitty-themes = "kitty +kitten themes";
        errorlog = "journalctl -p 3";
        zero="sudo zerotier-cli";
        zero-fix="sudo route add -host 255.255.255.255 dev ztks575eoa && route -n && sudo zerotier-cli status";
      };
      histSize = 3000;
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

    steam = { # Włącz steam
      enable = true;
      protontricks.enable = true; # Włącz wsparcie protontricks
      remotePlay.openFirewall = true; # Steam Remote Play
      dedicatedServer.openFirewall = true; # Otwórz porty dla Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Otwórz porty dla Steam Local Network Game Transfers
      extest.enable = true; # Tłumacz kliknięcia X11 na wayland dla steaminput
      extraCompatPackages = [ pkgs.proton-ge-bin ]; # Dodaje auto-aktualizowany proton-ge
    };

    gamescope = { # Włącz wsparcie Gamescope
      enable = true;
      capSysNice = true;
    };

    obs-studio = { # Włącz wsparcie Obs-studio
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [ waveform obs-vkcapture obs-tuna obs-text-pthread obs-pipewire-audio-capture obs-vaapi obs-gstreamer ];
    };
  };

  # Włącz keyring dla github-desktop
  #services.gnome.gnome-keyring.enable = true;
  #security.pam.services.sddm.enableGnomeKeyring = true;

  #programs.steam.package = pkgs.steam.override { withJava = true; };

  # Wersja systemu. By dokonać dużej aktualizacji, zmień stateVersion a następnie wpisz w terminal
  # sudo nix-channel --add https://channels.nixos.org/nixos-25.05 nixos
  system.stateVersion = "25.05";
}
