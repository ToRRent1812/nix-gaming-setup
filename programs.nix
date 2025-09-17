{ config, lib, pkgs, ... }:

{
# Programy zainstalowane dla wszystkich użytkowników, które nie posiadają modułów wbudowanych w nix (sekcja programs)
  environment.systemPackages = with pkgs; [
  # System
  nur.repos.novel2430.zen-browser-bin  # Przeglądarka
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
  kdePackages.kdenlive # Do montażu
  nur.repos.shadowrz.klassy-qt6 # Motyw Klassy, obecnie nie kompatybilne
  avidemux          # Przycinanie filmów
  haruna            # Oglądanie filmów
  papirus-icon-theme # Pakiet ikon
  darkly
  # Gaming tools
  mangohud          # FPSY, temperatury
  unstable.protonup-qt
  winetricks
  unstable.lutris   # Najnowszy lutris
  unstable.heroic   # Najnowszy Heroic Games Launcher
  adwsteamgtk       # Upiększ steam
  nur.repos.rogreat.faugus-launcher
  # Twitch/Youtube
  cameractrls       # Zarządzanie kamerą
  chatterino2       # Czytam chat
  audacious         # Muzyka
  audacious-plugins # Pluginy
  easyeffects       # Efekty mikrofonu
  scrcpy            # Przechwyć wideo z telefonu
  sqlitebrowser     # Przeglądaj bazę sqlite
  # Gry
  vcmi
  unstable.fheroes2
  (tetrio-desktop.override {withTetrioPlus = true;})
#Emulacja
  unstable.rpcs3
  unstable.pcsx2
  shadps4
  ppsspp
  unstable.xemu
  unstable.xenia-canary
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
