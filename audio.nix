{ config, lib, pkgs, ... }:

{
# Zezwól na audio w priorytecie realtime
  security.rtkit.enable = true;

  services = {
    pulseaudio.enable = false; # Systemowy pulseaudio

    pipewire = { # Włącz pipewire
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true; # Emulacja Pulseaudio
      extraConfig.pipewire."92-low-latency" = { # RT audio
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 32;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 32;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "32/48000";
            pulse.default.req = "32/48000";
            pulse.max.req = "32/48000";
            pulse.min.quantum = "32/48000";
            pulse.max.quantum = "32/48000";
          };
        }
        ];
        stream.properties = {
          node.latency = "32/48000";
          resample.quality = 10;
        };
      };
    };
  };
}
