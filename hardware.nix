{ config, lib, pkgs, ... }:

{
# Sprzęt
  hardware = {
    #xpadneo.enable = true;           # Włącz sterownik dla bezprzewodowego pada Xbox One
    #xone.enable = true;              # Włącz wsparcie xboxowego dongla usb, nie można łączyć z xpadneo
    steam-hardware.enable = true;     # Włącz wsparcie dla kontrolerów steamowych + Valve index

    amdgpu = {
      opencl.enable = true;      # Włącz OpenCL dla AMD GPU
      overdrive.enable = true;   # Pozwól na Overclock potrzebny przez program LACT
    };

    graphics = {
        enable = true;                # Aktywuj akcelerację w aplikacjach 64 bitowych
        enable32Bit = true;           # Aktywuj akcelerację w aplikacjach 32 bitowych
    };

    bluetooth = { # Ja nie mam bluetooth, to po co włączać
      enable = false;
      powerOnBoot = true;
    };

    uinput.enable = true; # Włącza tworzenie wirtualnych urządzeń, użyteczne do makro
  };

  ## Nvidia
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta; # Kanał Beta/New-Feature
  #services.xserver.videoDrivers = ["nvidia"];
  #hardware.nvidia = {
    #modesetting.enable = true;
    #open = true;
    #nvidiaSettings = true;
  #};

  # Dodaj wsparcie podpinania/odpinania dysków
  services = {
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
  };

  services.fstrim.enable = true; # Włącz trim dla SSD

  # Aktywuj wirtualizację dla virt managera
  virtualisation = {
    waydroid.enable = false;     # Android na linuxie
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker.enable = false;
  };
}
