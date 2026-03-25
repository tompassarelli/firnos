{ lib, ... }:
{
  options.myConfig.modules.gnome-screenshot.enable = lib.mkEnableOption "GNOME Screenshot tool";
  imports = [ ./gnome-screenshot.nix ];
}
