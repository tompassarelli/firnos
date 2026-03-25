{ lib, ... }:
{
  options.myConfig.gnome-screenshot.enable = lib.mkEnableOption "GNOME Screenshot tool";
  imports = [ ./gnome-screenshot.nix ];
}
