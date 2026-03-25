{ lib, ... }:
{
  options.myConfig.rofi.enable = lib.mkEnableOption "Rofi application launcher";

  imports = [
    ./rofi.nix
  ];
}
