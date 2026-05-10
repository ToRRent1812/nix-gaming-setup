{ config, lib, pkgs, ... }:

{
  security.rtkit.enable = true; # Zezwól na audio w priorytecie realtime

  services = {
    pulseaudio.enable = false; # Systemowy pulseaudio zamiast pipewire

    pipewire = { # Włącz pipewire
      enable = true;
      alsa.enable = true; # Włącz emulacje ALSA
      alsa.support32Bit = true;
      pulse.enable = true; # Włącz Emulacje Pulseaudio
      extraConfig.pipewire."92-low-latency" = { # Niskie opóźnienie
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [ 44100 48000 ];
          "default.clock.quantum" = 192;
          "default.clock.min-quantum" = 192;
          "default.clock.max-quantum" = 480;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "192/48000";
            pulse.default.req = "192/48000";
            pulse.max.req = "480/48000";
            pulse.min.quantum = "192/48000";
            pulse.max.quantum = "480/48000";
          };
        }
        ];
        stream.properties = {
          node.latency = "192/48000"; # Ustaw niskie opóźnienie
          resample.quality = 10; # Najlepsza jakość resamplingu
        };
      };
    };
  };
}
