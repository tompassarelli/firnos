{ lib, ... }:
{
  options.myConfig.modules.rofi.enable = lib.mkEnableOption "Rofi application launcher";

  imports = [
    ./rofi.nix
  ];
}
