{ config, lib, pkgs, ... }:

{
# Sprzęt
  hardware = {
    xpadneo.enable = true;            # Włącz sterownik xinput
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
  };

   #Wymień stabilny mesa na kanał niestabilny. Wymusi bardzo długą kompilację!!!
  #nixpkgs.overlays = [
  #  (self: super: {
  #    mesa = pkgs.unstable.mesa;
  #    mesa_drivers = pkgs.unstable.mesa_drivers;
  #    libGL = pkgs.unstable.libGL;
  #    libglvnd = pkgs.unstable.libglvnd;
  #    driversi686Linux.mesa = pkgs.unstable.driversi686Linux.mesa;
  #  })
  #];

  ## Nvidia
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta; # Kanał Beta/New-Feature
  #services.xserver.videoDrivers = ["nvidia"];
  #hardware.nvidia = {
    #modesetting.enable = true;
    #open = true;
    #nvidiaSettings = true;
  #};

  # Dodaj wsparcie podpinania pendrive (LOL)
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
