{ config, lib, pkgs, ... }:

{
# Ustawienia sieciowe
  networking = {
    hostName = "nixos"; # Nazwa hosta
    networkmanager.enable = true; # Włącz internet
    wireless.enable = false;  # Włącz WIFI
    firewall.enable = false; # Zapora sieciowa
    dhcpcd.wait = "background"; # Nie czekaj na internet by uruchomić system
    dhcpcd.extraConfig = "noarp";
    nameservers = [ "1.1.1.1" "1.0.0.1" ]; # Cloudflare DNS
  };
  systemd.services.NetworkManager-wait-online.enable = false;
}
