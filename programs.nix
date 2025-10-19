{ config, lib, pkgs, ... }:

{
# Programy zainstalowane dla wszystkich użytkowników, które nie posiadają modułów wbudowanych w nix (sekcja programs)
  environment.systemPackages = with pkgs; [
  
  ## System
  nur.repos.novel2430.zen-browser-bin   # Przeglądarka
  hunspell                              # Sprawdzanie pisowni
  hunspellDicts.pl-pl                   # Polski słownik
  hunspellDicts.en_US                   # Angielski słownik
  sublime4                              # Najlepszy edytor tekstu
  adwaita-icon-theme                    # Ikony dla aplikacji GTK4, np. do lutrisa
  epapirus-icon-theme                   # Ikony systemowe
  onlyoffice-desktopeditors             # Pakiet biurowy
  poedit                                # Program do tłumaczeń
  qbittorrent                           # Torrenty czasem się przydają
  rustdesk                              # Microsoft India Support
  qdirstat                              # Analiza dysków
  #nettools                             # narzędzia sieciowe potrzebne do zerotiera
  tealdeer                              # tldr w konsoli
  fastfetch                             # Informacje o systemie w terminalu
  gparted                               # Partycjonowanie dysków
  qpwgraph                              # Wizualny edytor połączeń dźwiękowych
  google-fonts                          # Paczka czcionek od Google Fonts
  p7zip                                 # Terminalowy 7-zip potrzebny do Gamma-launcher
  unrar                                 # Terminalowy rar/unrar potrzebny do Gamma-launcher

  ## KDE Plazma
  kdePackages.kdenlive                  # Do Edycji wideo  
  nur.repos.shadowrz.klassy-qt6         # Dekoracje okien Klassy
  avidemux                              # Przycinanie filmów
  haruna                                # Oglądanie filmów
  #darkly                               # Motyw Darkly

  ## Narzędzia do gier
  mangohud                              # FPSY, temperatury
  #unstable.protonup-qt                  # Aktualizacje proton-ge
  winetricks                            # Do instalacji bibliotek w wine
  unstable.lutris                       # Najnowszy lutris
  unstable.heroic                       # Najnowszy Heroic Games Launcher
  adwsteamgtk                           # Upiększ steam
  unstable.faugus-launcher		# Faugus Launcher
  #unstable.nexusmods-app-unfree        # Nexus Mods do modowania gier
  unstable.r2modman                     # Mod manager do Risk Of Rain 2 i innych
  wineWowPackages.stable                # wine stabilny

  ## Twitch/Youtube
  cameractrls-gtk4                      # Zarządzanie kamerą
  chatterino2                           # Czytam chat
  (audacious.override {withPlugins = true;}) # Muzyka
  easyeffects                           # Efekty mikrofonu/słuchawek
  scrcpy                                # Przechwyć obraz z telefonu
  sqlitebrowser                         # Przeglądaj bazę sqlite\

  ## Gry
  unstable.vcmi                         # Heroes 3
  bs-manager                            # Beat Saber Launcher
  unstable.fheroes2                     # Heroes 2
  nur.repos.ataraxiasjel.gamma-launcher # Stalker Gamma
  urbanterror                           # Urban Terror
  (tetrio-desktop.override {withTetrioPlus = true;}) # Tetris io

  ## Emulacja
  unstable.rpcs3                        # PS3
  duckstation                           # PS1
  unstable.pcsx2                        # PS2
  shadps4                               # PS4
  dolphin-emu                           # GameCube i Wii
  ppsspp                                # PSP 
  unstable.xemu                         # Xbox
  unstable.xenia-canary                 # Xbox 360
  mednaffe                              # TurboGrafx/Sega Genesis
  #fceux                                # NES
  
  ## Komunikacja
  (discord.override { withOpenASAR = true; withVencord = true; }) # Discord z vencord i openasar
  discord-rpc                           # Rich presence
  caprine                               # Messenger
  teamspeak3                            # TS3

  ## Programowanie + biblioteki do kdenlive AI
  github-desktop                        # GitHub       
  vscode-fhs                            # Programowanie
  hugo                                  # Do strony internetowej
  dotnet-sdk
  dotnet-runtime
  dotnet-aspnetcore
  gtk3
  godot
  (python3.withPackages (python-pkgs: with python-pkgs; [ # Do kdenlive AI
        pip
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
    kdeconnect.enable = true;           # Dodaj KDE Connect
    firefox.enable = false;             # Wyłącz Instalację Firefox
    thunderbird.enable = true;          # Dodaj mozilla thunderbird
    steam = { 
      enable = true;                    # Włącz steam
      protontricks.enable = true;       # dodaj protontricks
      remotePlay.openFirewall = true;   # Steam Remote Play
      dedicatedServer.openFirewall = true; # Otwórz porty dla Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Otwórz porty dla Steam Local Network Game Transfers
      extest.enable = true; # Tłumacz kliknięcia X11 na wayland dla steaminput
      extraCompatPackages = [ pkgs.proton-ge-bin ]; # Dodaje auto-aktualizowany proton-ge
    };

    gamescope = { # Włącz/wyłącz sesje Gamescope
      enable = false;
      capSysNice = true;
    };

    obs-studio = { # Dodaj Obs-studio
      enable = true;
      package = pkgs.unstable.obs-studio; # Wersja niestabilna dopóki aitum-multistream nie jest w stabilnej
      enableVirtualCamera = true;
      plugins = with pkgs.unstable.obs-studio-plugins; [ # Lista pluginów
        waveform
        obs-vkcapture
        obs-tuna
        obs-text-pthread
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-aitum-multistream
        ];
    };
};
}
