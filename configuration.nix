{ config, lib, pkgs, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
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
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
        inherit pkgs;
      };
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
      options = "--delete-older-than 14d";
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
      "vm.swappiness" = 10; #Procent aktywnego ruszania w swapie
      "vm.dirty_bytes" = 50331648; #To oraz opcje niżej przyspieszają kopiowanie na pendrive
      "vm.dirty_background_bytes" = 16777216;
      "vm.vfs_cache_pressure" = 75;
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      "net.ipv4.tcp_fin_timeout" = 5;
      "vm.dirty_ratio" = 3;
      "vm.dirty_background_ratio" = 2;
      "vm.dirty_expire_centisecs" = 3000;
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.min_free_kbytes" = 59030;
    };
  };

  # Szybsze zamykanie systemu
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=12s
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
    dhcpcd.wait = "background"; # Nie czekaj na internet by uruchomić system
    dhcpcd.extraConfig = "noarp";
    nameservers = [ "1.1.1.1" "1.0.0.1" ]; # Cloudflare DNS
  };

  systemd.services.NetworkManager-wait-online.enable = false;

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
      pulse.enable = true; # Emulacja Pulseaudio
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

    # VR
    wivrn = {
      enable = true;
      openFirewall = true;
      defaultRuntime = true;
      autoStart = false;
      extraPackages = [pkgs.xrizer];
    };
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

  xdg.terminal-exec = {
    enable = true;
    settings.default = ["kitty.desktop"];
  };

  # Programy zainstalowane dla wszystkich użytkowników, które nie posiadają modułów wbudowanych w nix (sekcja programs)
  environment.systemPackages = with pkgs; [
  # System
  #zen-browser            # Przeglądarka moja
  floorp
  kitty             # Ulubiony terminal
  gitkraken         # GUI dla git
  sublime4          # Najlepszy edytor tekstu
  vscode-fhs          # Programowanie
  adwaita-icon-theme # Ikony dla aplikacji GTK4
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
  kdePackages.discover # Odkrywca do flatpaków
  kdePackages.kdenlive # Do montażu
  nur.repos.shadowrz.klassy-qt6
  avidemux          # Przycinanie filmów
  haruna            # Oglądanie filmów
  #unstable.klassy-qt6 # Motyw Klassy, obecnie nie kompatybilne
  papirus-icon-theme # Pakiet ikon
  darkly
  # Gaming tools
  mangohud          # FPSY, temperatury
  unstable.protonup-qt
  winetricks
  unstable.umu-launcher # środowisko UMU do gier spoza steam
  unstable.lutris   # Najnowszy lutris
  unstable.heroic   # Najnowszy Heroic Games Launcher
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
  unstable.fheroes2
#Emulacja
  unstable.rpcs3
  unstable.pcsx2
  shadps4
  ppsspp
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
        system-upd = "tldr --update && flatpak update -y && sudo nix-channel --update && sudo nixos-rebuild boot --upgrade";
        live-upd = "tldr --update && flatpak update -y && sudo nix-channel --update && sudo nixos-rebuild switch --upgrade";
        repo-refresh = "sudo nix-channel --update";
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

    steam = { # Włącz steam
      enable = true;
      protontricks.enable = true; # Włącz wsparcie protontricks
      remotePlay.openFirewall = true; # Steam Remote Play
      dedicatedServer.openFirewall = true; # Otwórz porty dla Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Otwórz porty dla Steam Local Network Game Transfers
      extest.enable = true; # Tłumacz kliknięcia X11 na wayland dla steaminput
      #extraCompatPackages = [ pkgs.proton-ge-bin ]; # Dodaje auto-aktualizowany proton-ge
    };

    gamescope = { # Włącz/wyłącz wsparcie Gamescope
      enable = false;
      capSysNice = true;
    };

    obs-studio = { # Włącz wsparcie Obs-studio
      enable = true;
      #package = pkgs.unstable.obs-studio; # Tymczasowo póki aitum-multistream nie jest w stable
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [ waveform obs-vkcapture obs-tuna obs-text-pthread obs-pipewire-audio-capture obs-gstreamer];
    };
  };

  # Włącz keyring dla github-desktop
  #services.gnome.gnome-keyring.enable = true;
  #security.pam.services.sddm.enableGnomeKeyring = true;

  #programs.steam.package = pkgs.steam.override { withJava = true; };

# Kontrolery https://gitlab.com/fabiscafe/game-devices-udev
    services.udev.extraRules = ''
      # 8BitDo Generic Device
## This rule applies to many 8BitDo devices.
SUBSYSTEM=="usb", ATTR{idProduct}=="3106", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo F30 P1
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo F30 P2
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 II", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo N30
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SF30
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SFC30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SN30
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SNES30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo F30 Pro
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo N30 Pro
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SF30 Pro
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SF30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SN30 Pro
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SN30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SN30 Pro+; Bluetooth; USB
SUBSYSTEM=="input", ATTRS{name}=="8BitDo SN30 Pro+", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SF30 Pro   8BitDo SN30 Pro+", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo F30 Arcade
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo Joy", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo N30 Arcade
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 Arcade", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo ZERO
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo Zero GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Retro-Bit xRB8-64
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo N64 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Pro 2; Bluetooth; USB
SUBSYSTEM=="input", ATTRS{name}=="8BitDo Pro 2", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEM=="input", ATTR{id/vendor}=="2dc8", ATTR{id/product}=="6006", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEM=="input", ATTR{id/vendor}=="2dc8", ATTR{id/product}=="6003", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Pro 2 Wired; USB
# X-mode uses the 8BitDo Generic Device rule
# B-Mode
SUBSYSTEM=="usb", ATTR{idProduct}=="3010", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEMS=="input", ATTRS{id/product}=="3010", ATTRS{id/vendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Ultimate Wired Controller for Xbox; USB
SUBSYSTEM=="usb", ATTR{idProduct}=="2003", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Ultimate 2.4G Wireless  Controller; USB/2.4GHz
# X-mode uses the 8BitDo Generic Device rule
# D-mode
SUBSYSTEM=="usb", ATTR{idProduct}=="3012", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Ultimate 2C Wireless Controller; USB/2.4GHz
SUBSYSTEM=="usb", ATTR{idProduct}=="310a", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Arcade Stick; Bluetooth (X-mode)
SUBSYSTEM=="input", ATTRS{name}=="8BitDo Arcade Stick", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Ultimate 2 Wireless; Bluetooth; USB/2.4GHz
SUBSYSTEM=="input", ATTRS{name}=="8BitDo Ultimate 2 Wireless", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEM=="usb", ATTR{idProduct}=="310b", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# Sony PlayStation Strikepack; USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c5", MODE="0660", TAG+="uaccess"
# Sony PlayStation DualShock 3; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:0268*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0268", MODE="0660", TAG+="uaccess"
## Motion Sensors
SUBSYSTEM=="input", KERNEL=="event*|input*", KERNELS=="*054C:0268*", TAG+="uaccess"
# Sony PlayStation DualShock 4; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0660", TAG+="uaccess"
# Sony PlayStation DualShock 4 Slim; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0660", TAG+="uaccess"
# Sony PlayStation DualShock 4 Wireless Adapter; USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0660", TAG+="uaccess"
# Sony DualSense Wireless-Controller; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
# Sony DualSense Edge Wireless-Controller; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"
# Valve generic(all) USB devices
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
# Valve HID devices; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
# Microsoft Xbox 360 Controller; USB #EXPERIMENTAL
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="input", ATTRS{name}=="Microsoft X-Box 360 pad", MODE="0660", TAG+="uaccess"
# Microsoft Xbox 360 Wireless Receiver for Windows; USB
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="input", ATTRS{name}=="Xbox 360 Wireless Receiver", MODE="0660", TAG+="uaccess"
# Microsoft Xbox One S Controller; Bluetooth; USB #EXPERIMENTAL
KERNEL=="hidraw*", KERNELS=="*045e:02ea*", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0660", TAG+="uaccess"
# Microsoft Xbox One Controller; Bluetooth; USB
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02fd", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", KERNELS=="*045e:02fd*", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="input", ATTRS{name}=="Xbox Wireless Controller", MODE="0660", TAG+="uaccess"
# Hori RAP4
KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="008a", MODE="0660", TAG+="uaccess"
# Hori HORIPAD 4 FPS
KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="0055", MODE="0660", TAG+="uaccess"
# Hori HORIPAD 4 FPS Plus
KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="0066", MODE="0660", TAG+="uaccess"
# Hori HORIPAD S; USB
KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="00c1", MODE="0660", TAG+="uaccess"
# Hori Pokkén Tournament DX Pro Pad for Nintendo Switch; USB
KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="0092", MODE="0660", TAG+="uaccess"
# Hori Nintendo Switch HORIPAD Wired Controller; USB
KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="00c1", MODE="0660", TAG+="uaccess"
# Hori Wireless HORIPAD for Steam; USB
KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="01ab", MODE="0660", TAG+="uaccess"
    '';

  # Wersja systemu. By dokonać dużej aktualizacji, zmień stateVersion a następnie wpisz w terminal
  # sudo nix-channel --add https://channels.nixos.org/nixos-25.05 nixos
  system.stateVersion = "25.05";
}
