{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.pipewire.enable {
    # Audio with PipeWire
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };
  };
}
