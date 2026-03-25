{ lib, ... }:
{
  options.myConfig.modules.mpv.enable = lib.mkEnableOption "mpv media player";
  imports = [ ./mpv.nix ];
}
