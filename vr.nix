{ config, lib, pkgs, ... }:

{
# Wszystko strikte związane z VR
    services.wivrn = {
      enable = true;
      openFirewall = true;
      defaultRuntime = true;
      autoStart = false;
      extraPackages = [pkgs.xrizer];
    };

    programs.alvr = {
        enable = true;
        openFirewall = true;
    };
}
