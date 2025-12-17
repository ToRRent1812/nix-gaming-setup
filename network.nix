{ config, lib, pkgs, ... }:

{
# Ustawienia sieciowe
  networking = {
    hostName = "nixos";             # Nazwa hosta
    networkmanager.enable = true;   # Włącz internet
    wireless.enable = false;        # Włącz wsparcie WIFI
    firewall.enable = false;        # Zapora sieciowa
    enableIPv6 = false;             # Włącz wsparcie IPv6
    dhcpcd.wait = "background";     # Nie czekaj na internet by uruchomić system
    dhcpcd.extraConfig = "noarp";   # Przyspiesza działanie sieci
    nameservers = [ "1.1.1.1" "1.0.0.1" ]; # Cloudflare DNS
  };
  systemd.services.NetworkManager-wait-online.enable = false; # Nie czekaj na internet by uruchomić system

  services.zerotierone = {
      enable = true;                # Włącz usługę ZeroTier do grania z kolegami po LAN
    };
}
