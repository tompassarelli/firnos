{ lib, ... }:
{
  options.myConfig.obs-studio.enable = lib.mkEnableOption "OBS Studio screen recording";
  imports = [ ./obs-studio.nix ];
}
