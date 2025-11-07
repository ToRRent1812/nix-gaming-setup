{ config, lib, pkgs, ... }:

{
# Wszystko strikte związane z VR
    services.wivrn = {
      enable = true;       # Dodaj WiVRN
      openFirewall = true; # Otwórz zaporę sieciową dla WiVRN
      defaultRuntime = true; # Ustaw jako domyślny runtime openXR
      highPriority = true;  # Ustaw wysoki priorytet procesu
      autoStart = false;    # Nie uruchamiaj automatycznie przy starcie systemu
      steam.importOXRRuntimes = true; # Importuj runtime openXR do Steama
    };

    programs.alvr = {
        enable = true;       # Dodaj ALVR
        openFirewall = true; # Otwórz zaporę sieciową dla ALVR
        package = pkgs.unstable.alvr; # Użyj najnowszej wersji ALVR z kanału niestabilnego
    };
}
