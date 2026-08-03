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

    # Wysoki priorytet gier dzięki ananicy od cachyos. Gryzie się z scx_lavd
    ananicy = {
      enable = false;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    # Lokalny dyrygent/scheduler który podobno polepsza działanie komputera w stresie
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    # Serwer lokalny od odtwarzania muzyki z komputera. Super lekki
    mpd = {
      enable = true;
      user = "rabbit";
      settings.music_directory = "/home/rabbit/Muzyka";
      settings.playlist_directory = "/home/rabbit/Muzyka/MPDPlaylisty";

      settings = {
        audio_output = [
        {
          type = "pipewire";
          name = "Pipewire Sound Server";
        }];
      };

      startWhenNeeded = true;
    };

    xserver.xkb = { # Polska klawiatura
      layout = "pl";
      variant = "";
    };

    udev.packages = with pkgs; [
      game-devices-udev-rules
    ];
    #ACTION=="add", SUBSYSTEM=="input", ENV{ID_INPUT_JOYSTICK}=="1", ENV{ID_VENDOR_ID}=="3537", ENV{ID_MODEL_ID}=="1093", RUN+="/run/current-system/sw/bin/sh -c '/run/current-system/sw/bin/evdev-joystick --e /dev/input/by-id/usb-3537_Controller_00006F64096B22E0-event-joystick --axis 2 --deadzone 16 --fuzz 16; /run/current-system/sw/bin/evdev-joystick --e /dev/input/by-id/usb-3537_Controller_00006F64096B22E0-event-joystick --axis 5 --deadzone 16 --fuzz 16'"

    # Zasady udev bym mógł konfigurować mysz i klawiaturę w programie, pierwsze dwie to mchose a7 v2 ultra, trzecia to akko mod 008
    udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="3837", ATTRS{idProduct}=="100b", MODE="0666", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3837", ATTRS{idProduct}=="4019", MODE="0666", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3151", ATTRS{idProduct}=="4002", MODE="0666", TAG+="uaccess"
    '';

    # Raz w miesiącu, wykonuje auto scrub dysku
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/mnt/nvme" ];
    };

    # Automatyczna deduplikacja dysku btrfs
    beesd.filesystems = {
      root = {
        spec = "/mnt/nvme";
        hashTableSizeMB = 2048;
        verbosity = "crit";
        extraOptions = [ "--loadavg-target" "5.0" ];
      };
    };

    displayManager = {
      sddm.enable = true; # SDDM Plasma login manager
      sddm.wayland.enable = true; # Włącz SDDM w trybie Wayland
      autoLogin.user = "rabbit";  # Użytkownik do automatycznego logowania
      autoLogin.enable = true;    # Włącz automatyczne logowanie
      defaultSession = "plasma";  # Plasma-wayland jako default lub plasmax11 dla x11
    };
    desktopManager.plasma6.enable = true; # Plasma 6

    printing.enable = false; # Wsparcie drukarek

    libinput.enable = false; # Wsparcie touchpadów
  };

  # Do MPD by użytkownik miał prawa
  systemd.services.mpd.environment = { XDG_RUNTIME_DIR = "/run/user/1000"; };
}
