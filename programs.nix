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
  papirus-icon-theme                    # Ikony systemowe
  onlyoffice-desktopeditors             # Pakiet biurowy
  stable.poedit                         # Program do tłumaczeń
  rustdesk                              # Microsoft India Support
  qdirstat                              # Analiza dysków
  tealdeer                              # tldr w konsoli
  fastfetch                             # Informacje o systemie w terminalu
  #gparted                              # Partycjonowanie dysków
  qpwgraph                              # Wizualny edytor połączeń dźwiękowych
  qbittorrent                           # Klient do torrentów
  #winboat                              # Windows apki w Linux
  google-fonts                          # Paczka czcionek od Google Fonts
  unrar
  gearlever

  ## KDE Plazma
  kdePackages.kdenlive                  # Do Edycji wideo
  klassy                                # Dekoracje okien Klassy
  avidemux                              # Przycinanie filmów
  haruna                                # Oglądanie filmów
  (audacious.override { withPlugins = true; }) # Muzyka
  handbrake                             # Konwerter filmów

  ## Narzędzia do gier
  sidequest
  mangohud                              # FPSY, temperatury
  wineWow64Packages.staging             # najnowszy wine-staging
  protonplus                            # Aktualizacje proton-ge
  winetricks                            # Do instalacji bibliotek w wine
  lutris                                # Najnowszy lutris
  heroic                                # Najnowszy Heroic Games Launcher
  faugus-launcher                       # Faugus Launcher
  gale                                  # Mod Manager dla wielu gier indie(Thunderstore)
  wayvr

  ## Twitch/Youtube
  (cameractrls.override {withGtk = 3;}) # Zarządzanie kamerą
  chatterino2                           # Czytam chat
  easyeffects                           # Efekty mikrofonu/słuchawek
  #scrcpy                               # Przechwyć obraz z telefonu
  sqlitebrowser                         # Przeglądaj bazę sqlite

  ## Gry
  bs-manager                            # Beat Saber Launcher
  fheroes2                              # Heroes 2
  vcmi                                  # VCMI
  urbanterror                           # Urban Terror

  ## Emulacja
  rpcs3                                 # PS3
  pcsx2                                 # PS2
  shadps4                               # PS4
  dolphin-emu                           # GameCube i Wii
  ppsspp                                # PSP 
  xemu                                  # Xbox
  xenia-canary                          # Xbox 360
  mednaffe                              # TurboGrafx/Sega Genesis
  stable.flycast                        # Dreamcast
  nestopia-ue                           # NES
  mame                                  # Arcade
  
  ## Komunikacja
  (discord.override { withOpenASAR = true; withVencord = true; }) # Discord z vencord i openasar
  discord-rpc                           # Rich presence
  caprine                               # Messenger

  ## Programowanie + biblioteki do kdenlive AI
  github-desktop                        # GitHub       
  flatpak-builder                       # Do tworzenia flatpaków
  vscode-fhs                            # Programowanie
  hugo                                  # Do strony internetowej
  dotnet-sdk                            # .NET SDK do kompilacji modów CS2
  dotnet-runtime
  dotnet-aspnetcore
  gtk3
  (python3.withPackages (python-pkgs: with python-pkgs; [ # Do kdenlive AI
        pip
        openai-whisper
        srt
        torch
        torchvision
        pillow
        hydra-core
        iopath
        sam2
        opencv4
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
    };

    gamescope = {
      enable = true;                      # Dodaj/usuń Gamescope
      capSysNice = false;                 # Zezwól na wysoki priorytet
    };

    obs-studio = {
      enable = true;                      # Dodaj obs-studio do systemu
      enableVirtualCamera = true;         # Wsparcie wirtualnej kamery
      plugins = with pkgs.obs-studio-plugins; [ # Lista pluginów
        waveform
        obs-vkcapture
        obs-tuna
        obs-text-pthread
        obs-retro-effects
        obs-stroke-glow-shadow
        ];
    };
};
}
