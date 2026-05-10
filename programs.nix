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
  poedit                                # Program do tłumaczeń
  qdirstat                              # Analiza dysków
  tealdeer                              # tldr w konsoli
  fastfetch                             # Informacje o systemie w terminalu
  gparted                               # Partycjonowanie dysków
  qpwgraph                              # Wizualny edytor połączeń dźwiękowych
  qbittorrent                           # Klient do torrentów
  google-fonts                          # Paczka czcionek od Google Fonts
  unrar                                 # Wypakowywanie archiwów .rar
  p7zip                                 # Wypakowywanie archiwów .7z
  gearlever                             # Pomocnik plików appimage
  kitty                                 # Terminal ze wsparciem GPU
  btrfs-assistant                       # Asystent dysków btrfs
  alsa-utils                            # alsamixer czasem się przydaje
  waydroid-helper                      # Pomocnik zarządzania waydroidem
  #distrobox                            # Kontenery dystrybucji
  #kontainer                            # GUI do Distroboxa

  ## KDE Plazma
  kdePackages.kdenlive                  # Do Edycji wideo
  klassy                                # Dekoracje okien Klassy
  avidemux                              # Przycinanie filmów
  haruna                                # Oglądanie filmów
  cantata                               # Klient do słuchania muzyki z MPD
  kid3-kde                              # Program do tagowania muzyki

  ## Narzędzia do gier
  sidequest
  mangohud                              # FPSY, temperatury
  protonplus                            # Aktualizacje proton-ge
  winetricks                            # Do instalacji bibliotek w wine
  lutris                                # Najnowszy lutris
  heroic                                # Najnowszy Heroic Games Launcher
  faugus-launcher                       # Faugus Launcher
  gale                                  # Mod Manager dla wielu gier indie(Thunderstore)
  wayvr                                 # Dashboard VR
  hydralauncher                         # Do gier z zatoki

  ## Twitch/Youtube
  (cameractrls.override {withGtk = 3;}) # Zarządzanie kamerą
  chatterino2                           # Czytam chat
  #easyeffects                           # Efekty mikrofonu/słuchawek
  #scrcpy                               # Przechwyć obraz z telefonu
  sqlitebrowser                         # Przeglądaj bazę sqlite

  ## Gry
  bs-manager                            # Beat Saber Launcher
  urbanterror                           # Urban Terror

  ## Emulacja
  xenia-canary                          # Xbox 360
  mame                                  # Arcade
  
  ## Komunikacja
  (discord.override { withOpenASAR = true; withVencord = false; }) # Discord z vencord i openasar
  discord-rpc                           # Rich presence
  caprine                               # Messenger

  ## Programowanie + biblioteki do kdenlive AI
  stable.github-desktop                        # GitHub
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
        #sam2
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
    direnv.enable = true;               # Do programowania w vscode
    direnv.nix-direnv.enable = true;           # Lepszy direnv do cachowania paczek w shellu
    steam = { 
      enable = true;                                  # Włącz steam
      protontricks.enable = true;                     # dodaj protontricks
      remotePlay.openFirewall = true;                 # Steam Remote Play
      dedicatedServer.openFirewall = true;            # Otwórz porty dla Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true;  # Otwórz porty dla Steam Local Network Game Transfers
      #extest.enable = true;                           # Tłumacz kliknięcia X11 na wayland dla steaminput
    };

    gamescope = {
      enable = true;                      # Dodaj/usuń Gamescope
      capSysNice = false;                 # Zezwól na wysoki priorytet
    };

    obs-studio = {
      enable = true;                      # Dodaj obs-studio do systemu
      enableVirtualCamera = false;         # Wsparcie wirtualnej kamery
      plugins = with pkgs.obs-studio-plugins; [ # Lista pluginów
        waveform
        input-overlay
        obs-aitum-multistream
        obs-vkcapture
        obs-tuna
        obs-text-pthread
        obs-retro-effects
        obs-stroke-glow-shadow
        ];
    };
};
}
