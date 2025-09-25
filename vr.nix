{ config, lib, pkgs, ... }:

{
# Wszystko strikte związane z VR
    services.wivrn = {
      enable = true; # Dodaj WiVRN
      openFirewall = true;
      defaultRuntime = true;
      #highPriority = true;
      autoStart = false;
      #steam.importOXRRuntimes = true;
    };

    programs.alvr = {
        enable = true; # Dodaj ALVR
        openFirewall = true;
        package = pkgs.unstable.alvr;
    };
}
