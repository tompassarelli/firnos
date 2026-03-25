{ lib, ... }:
{
  options.myConfig.pavucontrol.enable = lib.mkEnableOption "PulseAudio volume control";
  imports = [ ./pavucontrol.nix ];
}
