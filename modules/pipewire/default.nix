{ config, lib, ... }:
{
  options.myConfig.modules.pipewire = {
    enable = lib.mkEnableOption "PipeWire audio configuration";
  };

  config = lib.mkIf config.myConfig.modules.pipewire.enable {
    # Audio with PipeWire
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };
  };
}
