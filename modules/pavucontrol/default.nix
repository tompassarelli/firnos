{ lib, ... }:
{
  options.myConfig.modules.pavucontrol.enable = lib.mkEnableOption "PulseAudio volume control";
  imports = [ ./pavucontrol.nix ];
}
