{ config, lib, pkgs, ... }:

{
## Przypinanie jądra na konkretną wersję
    #nixpkgs.overlays = [
   # (final: prev: { linuxPackages_zen = pkgs.pinnedkernel.linuxPackages_zen;})];
# Bootloader
  boot = {
    loader.efi.canTouchEfiVariables = true;       # Pozwól na modyfikację zmiennych EFI
    loader.limine = {
      enable = true;            # Użyj Limine
      efiSupport = true;
      style.wallpapers = [pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath];
      extraConfig = "timeout:2";
      extraEntries = ''
        /Windows
          protocol: efi
          path: uuid(9b4c23ad-8c11-4ace-a1f5-0bc00d75acc5):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
    tmp.cleanOnBoot = true;                       # Czyszczenie TMP przy ładowaniu systemu
    kernelPackages = pkgs.linuxPackages_zen;   # Jądro systemu https://nixos.wiki/wiki/Linux_kernel
    #extraModulePackages = with config.boot.kernelPackages; [ vhba ntsync ]; # Dodatkowe moduły/sterowniki jądra
    kernelModules = ["vhba" "ntsync"];
    kernelParams = [ "nohibernate" "usbcore.autosuspend=-1" "mitigations=off" "loglevel=2" ]; # Parametry jądra
    kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0;           # Wyłącza split_lock, rekomendowane do gier
      "vm.max_map_count" = 2147483642;            # Jak w SteamOS, niemal maksymalny możliwy map_count
      "vm.swappiness" = 10;                       # Procent aktywnego ruszania w swapie
      "vm.vfs_cache_pressure" = 50;               # Mniej agresywne czyszczenie cache
      "kernel.sched_cfs_bandwidth_slice_us" = 3000; # Krótszy czas przydzielania CPU na proces
      "net.ipv4.tcp_fin_timeout" = 5;               # Szybsze zamykanie połączeń TCP
      "vm.dirty_ratio" = 3;                       # To oraz opcje niżej przyspieszają kopiowanie na pendrive
      "vm.dirty_bytes" = 50331648; 
      "vm.dirty_background_bytes" = 16777216;
      "vm.dirty_background_ratio" = 2;
      "vm.dirty_expire_centisecs" = 3000;
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.min_free_kbytes" = 59030;
    };
    supportedFilesystems = ["exfat" "btrfs" "ntfs"];
  };

  # Szybsze zamykanie systemu
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "12s";
  };

  # Optymalizacja RAM
  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

  # Profil zasilania CPU
  powerManagement = {
        enable = true;
        powertop.enable = true;
        cpuFreqGovernor = "performance"; #power, performance, ondemand
  };
}
