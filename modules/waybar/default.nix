{ lib, ... }:
{
  options.myConfig.waybar = {
    enable = lib.mkEnableOption "Waybar status bar for Wayland";
  };

  imports = [
    ./waybar.nix
  ];
}
