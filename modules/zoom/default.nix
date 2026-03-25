{ lib, ... }:
{
  options.myConfig.zoom.enable = lib.mkEnableOption "Zoom video conferencing";
  imports = [ ./zoom.nix ];
}
