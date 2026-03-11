{ lib, ... }:
{
  options.myConfig.rofi-wayland = {
    enable = lib.mkEnableOption "Rofi application launcher for Wayland";
  };

  imports = [
    ./rofi-wayland.nix
  ];
}
