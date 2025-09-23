{ config, lib, pkgs, ... }:

{
# Bootloader
  boot = {
    loader.systemd-boot.enable = true;            # Użyj systemd-boot
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_zen;      # Jądro ZEN dla graczy
    extraModulePackages = [ config.boot.kernelPackages.vhba ]; # Dodatkowe moduły/sterowniki jądra
    kernelParams = [ "usbcore.autosuspend=600" "mitigations=off" ]; # Parametry jądra
    kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0;           # Wyłącza split_lock, rekomendowane do gier
      "vm.max_map_count" = 2147483642;            # Jak w SteamOS, niemal maksymalny możliwy map_count
      "vm.swappiness" = 10;                       # Procent aktywnego ruszania w swapie
      "vm.vfs_cache_pressure" = 75;               # Mniej agresywne czyszczenie cache
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
    supportedFilesystems.exfat = true;            # Obsługa exFAT którą potrzebuje do pendrive
  };

  # Szybsze zamykanie systemu
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=12s
  '';

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

  # Wysoka wydajność AMD GPU
  systemd.services.highgpu = {
    enable = true;
    wantedBy = [ "default.target" ];
    after = [ "graphical.target" ];
    description = "AMD GPU set to High";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "sudo /run/current-system/sw/bin/sh -c 'echo high > /sys/class/drm/card1/device/power_dpm_force_performance_level'";
    };
  };
}
