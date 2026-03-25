{ lib, ... }:
{
  options.myConfig.modules.obs-studio.enable = lib.mkEnableOption "OBS Studio screen recording";
  imports = [ ./obs-studio.nix ];
}
