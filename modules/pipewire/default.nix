{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.pipewire;
in
{
  options.myConfig.modules.pipewire.enable = lib.mkEnableOption "PipeWire audio configuration";
  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };
  };
}
