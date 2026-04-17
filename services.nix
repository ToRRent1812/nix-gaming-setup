{ config, lib, pkgs, ... }:
{
# Usługi
  services = {
    fwupd.enable = true;          # Włącz wsparcie aktualizatora firmware
    swapspace.enable = true;      # Dynamicznie powiększa i pomniejsza swap gdy jest potrzeba
    xserver.enable = false;       # Włącz sesję X11. Wyłącz by zostawić tylko Wayland
    passSecretService.package = pkgs.libsecret; # Wsparcie dla menedżera haseł, wymagane do niektórych programów
    passSecretService.enable = true;  # Włącz wsparcie dla menedżera haseł
    envfs.enable = true;              # Wsparcie dla envfs, wymagane do niektórych programów
    lact.enable = true;          # Dodaj menedżer zarządzania AMD, musi być też włączony hardware.amdgpu.overdrive.enable

    # Wysoki priorytet gier dzięki ananicy od cachyos
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    xserver.xkb = { # Polska klawiatura
      layout = "pl";
      variant = "";
    };

    udev.packages = with pkgs; [
      game-devices-udev-rules
    ];

    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/mnt/nvme" ];
    };

    beesd.filesystems = {
      root = {
      spec = "LABEL=/mnt/nvme";
      hashTableSizeMB = 2048;
      verbosity = "crit";
      extraOptions = [ "--loadavg-target" "5.0" ];
    };
};

    displayManager = {
      sddm.enable = true; # Plasma login manager
      sddm.wayland.enable = true; # Włącz SDDM w trybie Wayland
      autoLogin.user = "rabbit";  # Użytkownik do automatycznego logowania
      autoLogin.enable = true;    # Włącz automatyczne logowanie
      defaultSession = "plasma";  # Plasma-wayland jako default
    };
    desktopManager.plasma6.enable = true; # Plasma 6

    printing.enable = false; # Wsparcie drukarek

    libinput.enable = false; # Wsparcie touchpadów
  };
}
