{ config, lib, pkgs, ... }:

{
# Wszystko strikte związane z VR
    services.wivrn = {
      enable = true;       # Dodaj WiVRN
      openFirewall = true; # Otwórz zaporę sieciową dla WiVRN
      highPriority = true;  # Ustaw wysoki priorytet procesu
      steam.importOXRRuntimes = true; # Importuj runtime openXR do Steama
    };

    programs.alvr = {
        enable = false;       # Dodaj ALVR
        openFirewall = true; # Otwórz zaporę sieciową dla ALVR
    };
}
