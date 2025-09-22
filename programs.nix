{ config, lib, pkgs, ... }:

{
# Programy zainstalowane dla wszystkich użytkowników, które nie posiadają modułów wbudowanych w nix (sekcja programs)
  environment.systemPackages = with pkgs; [
  # System
  nur.repos.novel2430.zen-browser-bin  # Przeglądarka
  kitty             # Ulubiony terminal
  gtk3         # GUI Potrzebne do niektórych programów
  github-desktop
  #dotnetCorePackages.dotnet_8.sdk
  sublime4          # Najlepszy edytor tekstu
  vscode-fhs          # Programowanie
  adwaita-icon-theme # Ikony dla aplikacji GTK4
  epapirus-icon-theme
  hugo              # Strona internetowa
  onlyoffice-desktopeditors # Pakiet biurowy
  #upscaler          # Upscale zdjęć
  qbittorrent       # Torrenty czasem się przydają
  rustdesk-flutter # Zdalny pulpit
  qdirstat          # Analiza danych
  #nettools          # narzędzia sieciowe
  tealdeer          # tldr w konsoli
  fastfetch
  gparted
# KDE Plazma
  kdePackages.kdenlive # Do montażu
  nur.repos.shadowrz.klassy-qt6 # Motyw Klassy, obecnie nie kompatybilne
  avidemux          # Przycinanie filmów
  haruna            # Oglądanie filmów
  darkly
  # Gaming tools
  mangohud          # FPSY, temperatury
  unstable.protonup-qt
  winetricks
  unstable.lutris   # Najnowszy lutris
  unstable.heroic   # Najnowszy Heroic Games Launcher
  adwsteamgtk       # Upiększ steam
  nur.repos.rogreat.faugus-launcher
  #unstable.nexusmods-app-unfree
  r2modman # Mod manager
  # Twitch/Youtube
  cameractrls-gtk4       # Zarządzanie kamerą
  chatterino2       # Czytam chat
  audacious         # Muzyka
  audacious-plugins # Pluginy
  easyeffects       # Efekty mikrofonu
  scrcpy            # Przechwyć wideo z telefonu
  sqlitebrowser     # Przeglądaj bazę sqlite
  # Gry
  vcmi		    # Heroes 3
  bs-manager 	    # Beat Saber Launcher
  unstable.fheroes2 # Heroes 2
  (tetrio-desktop.override {withTetrioPlus = true;})
#Emulacja
  unstable.rpcs3
  #ps3-disk-dumper
  #unstable.pcsx2
  #shadps4
  #dolphin-emu
  #ppsspp
  unstable.xemu
  unstable.xenia-canary
  #fceux
  # Komunikacja
  (discord.override { withOpenASAR = true; withVencord = true; })
  discord-rpc       # Rich presence
  caprine           # Messenger
  teamspeak3        # TS3
# Pytong dla kdenlive AI + programowanie 
dotnet-sdk
dotnet-runtime
dotnet-aspnetcore
(python3.withPackages (python-pkgs: with python-pkgs; [
        pip
	pygobject3
        openai-whisper
        srt
        torch
      ]))
  ];

environment.plasma6.excludePackages = with pkgs.kdePackages; [ #Usuwanie zbędnych aplikacji domyślnych z plazmy
  kdepim-runtime
  elisa
];

environment.variables = rec { # Naprawia integracje systemu z GTK (Np Zen browser)
    GSETTINGS_SCHEMA_DIR="${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  }; 

programs = {
    kdeconnect.enable = true; # KDE Connect
    firefox.enable = false; # Wyłącz Instalację Firefox
    thunderbird.enable = true; # Aktywuj mozilla thunderbird
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
      package = pkgs.unstable.obs-studio;
      enableVirtualCamera = true;
      plugins = with pkgs.unstable.obs-studio-plugins; [ waveform obs-vkcapture obs-tuna obs-text-pthread obs-pipewire-audio-capture obs-gstreamer obs-aitum-multistream];
    };
};
}
