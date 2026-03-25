{ lib, ... }:
{
  options.myConfig.mpv.enable = lib.mkEnableOption "mpv media player";
  imports = [ ./mpv.nix ];
}
