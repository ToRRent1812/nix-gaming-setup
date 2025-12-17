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

    xserver.xkb = { # Polska klawiatura
      layout = "pl";
      variant = "";
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
    # Wsparcie kontrolerów https://gitlab.com/fabiscafe/game-devices-udev
    udev.extraRules = ''
      # 8BitDo Generic Device
## This rule applies to many 8BitDo devices.
SUBSYSTEM=="usb", ATTR{idProduct}=="3106", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo F30 P1
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo F30 P2
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 II", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo N30
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SF30
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SFC30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SN30
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SNES30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo F30 Pro
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo N30 Pro
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SF30 Pro
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SF30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SN30 Pro
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SN30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo SN30 Pro+; Bluetooth; USB
SUBSYSTEM=="input", ATTRS{name}=="8BitDo SN30 Pro+", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SF30 Pro   8BitDo SN30 Pro+", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo F30 Arcade
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo Joy", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo N30 Arcade
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 Arcade", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo ZERO
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo Zero GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Retro-Bit xRB8-64
SUBSYSTEM=="input", ATTRS{name}=="8Bitdo N64 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Pro 2; Bluetooth; USB
SUBSYSTEM=="input", ATTRS{name}=="8BitDo Pro 2", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEM=="input", ATTR{id/vendor}=="2dc8", ATTR{id/product}=="6006", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEM=="input", ATTR{id/vendor}=="2dc8", ATTR{id/product}=="6003", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Pro 2 Wired; USB
# X-mode uses the 8BitDo Generic Device rule
# B-Mode
SUBSYSTEM=="usb", ATTR{idProduct}=="3010", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEMS=="input", ATTRS{id/product}=="3010", ATTRS{id/vendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Ultimate Wired Controller for Xbox; USB
SUBSYSTEM=="usb", ATTR{idProduct}=="2003", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Ultimate 2.4G Wireless  Controller; USB/2.4GHz
# X-mode uses the 8BitDo Generic Device rule
# D-mode
SUBSYSTEM=="usb", ATTR{idProduct}=="3012", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Ultimate 2C Wireless Controller; USB/2.4GHz
SUBSYSTEM=="usb", ATTR{idProduct}=="310a", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Arcade Stick; Bluetooth (X-mode)
SUBSYSTEM=="input", ATTRS{name}=="8BitDo Arcade Stick", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# 8BitDo Ultimate 2 Wireless; Bluetooth; USB/2.4GHz
SUBSYSTEM=="input", ATTRS{name}=="8BitDo Ultimate 2 Wireless", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
SUBSYSTEM=="usb", ATTR{idProduct}=="310b", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
# Sony PlayStation Strikepack; USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c5", MODE="0660", TAG+="uaccess"
# Sony PlayStation DualShock 3; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:0268*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0268", MODE="0660", TAG+="uaccess"
## Motion Sensors
SUBSYSTEM=="input", KERNEL=="event*|input*", KERNELS=="*054C:0268*", TAG+="uaccess"
# Sony PlayStation DualShock 4; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0660", TAG+="uaccess"
# Sony PlayStation DualShock 4 Slim; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0660", TAG+="uaccess"
# Sony PlayStation DualShock 4 Wireless Adapter; USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0660", TAG+="uaccess"
# Sony DualSense Wireless-Controller; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
# Sony DualSense Edge Wireless-Controller; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"
# Valve generic(all) USB devices
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
# Valve HID devices; Bluetooth; USB
KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
# Microsoft Xbox 360 Controller; USB #EXPERIMENTAL
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="input", ATTRS{name}=="Microsoft X-Box 360 pad", MODE="0660", TAG+="uaccess"
# Microsoft Xbox 360 Wireless Receiver for Windows; USB
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="input", ATTRS{name}=="Xbox 360 Wireless Receiver", MODE="0660", TAG+="uaccess"
# Microsoft Xbox One S Controller; Bluetooth; USB #EXPERIMENTAL
KERNEL=="hidraw*", KERNELS=="*045e:02ea*", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0660", TAG+="uaccess"
# Microsoft Xbox One Controller; Bluetooth; USB
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02fd", MODE="0660", TAG+="uaccess"
KERNEL=="hidraw*", KERNELS=="*045e:02fd*", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="input", ATTRS{name}=="Xbox Wireless Controller", MODE="0660", TAG+="uaccess"
    '';
  };
}
