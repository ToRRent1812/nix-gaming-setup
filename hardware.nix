{ config, lib, pkgs, ... }:

{
# Sprzęt
  hardware = {
    xpadneo.enable = true; # Włącz sterownik xinput
    #xone.enable = true; # Włącz wsparcie xboxowego dongla usb
    steam-hardware.enable = true;

    graphics = {
        enable = true; # Aktywuj akcelerację w aplikacjach 64 bitowych
        enable32Bit = true; # Aktywuj akcelerację w aplikacjach 32 bitowych
    };

    bluetooth = { # Ja nie mam bluetooth, to po co włączać
      enable = false;
      powerOnBoot = true;
    };
  };

    # Nvidia
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta; // Kanał Beta/New-Feature
  #services.xserver.videoDrivers = ["nvidia"];
  #hardware.nvidia = {
    #modesetting.enable = true;
    #open = true;
    #nvidiaSettings = true;
  #};

  # Aktywuj wirtualizację dla virt managera
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker.enable = false;
  };
}
