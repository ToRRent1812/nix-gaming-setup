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
      extraPackages = [pkgs.xrizer];
    };

    programs.alvr = {
        enable = true; # Dodaj ALVR
        openFirewall = true;
    };
}
