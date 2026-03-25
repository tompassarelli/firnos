{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.pavucontrol.enable = lib.mkEnableOption "PulseAudio volume control";

  config = lib.mkIf config.myConfig.modules.pavucontrol.enable {
    environment.systemPackages = [ pkgs.pavucontrol ];
  };
}
