{ lib, ... }:
{
  options.myConfig.upower = {
    enable = lib.mkEnableOption "UPower power management";
  };

  imports = [
    ./upower.nix
  ];
}
