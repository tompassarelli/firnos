{ lib, ... }:
{
  options.myConfig.modules.zoom.enable = lib.mkEnableOption "Zoom video conferencing";
  imports = [ ./zoom.nix ];
}
