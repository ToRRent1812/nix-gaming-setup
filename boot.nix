{ config, lib, pkgs, ... }:

{
# Bootloader
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/vda";
      useOSProber = true; # Dodaj Windows do bootloadera
    };
    kernelPackages = pkgs.linuxPackages_zen; # Jądro systemu zen dla graczy
    extraModulePackages = with config.boot.kernelPackages; [ vhba ]; # Dodatkowe moduły/sterowniki jądra których nie ma niżej
    kernelParams = [ "mitigations=off" ];
    kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0; #Wyłącza split_lock, rekomendowane do gier
      "vm.max_map_count" = 2147483642; #Jak w SteamOS, niemal maksymalny możliwy map_count
      "vm.swappiness" = 10; #Procent aktywnego ruszania w swapie
      "vm.dirty_bytes" = 50331648; #To oraz opcje niżej przyspieszają kopiowanie na pendrive
      "vm.dirty_background_bytes" = 16777216;
      "vm.vfs_cache_pressure" = 75;
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      "net.ipv4.tcp_fin_timeout" = 5;
      "vm.dirty_ratio" = 3;
      "vm.dirty_background_ratio" = 2;
      "vm.dirty_expire_centisecs" = 3000;
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.min_free_kbytes" = 59030;
    };
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
  systemd.user.services.highgpu = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "AMD GPU set to High";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/bash -c 'echo high > /sys/class/drm/card1/device/power_dpm_force_performance_level'";
    };
  };
}
