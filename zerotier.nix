{ config, lib, pkgs, ... }:

{
    services.zerotierone = {
      enable = true; # Włącz usługę ZeroTier do grania z kolegami po LAN
      joinNetworks = [ "17d709436cf7d2ac" ]; # ID mojej sieci ZeroTier
    };
}
