{ lib, ... }:
{
  options.myConfig.modules.upower = {
    enable = lib.mkEnableOption "UPower power management";
  };

  imports = [
    ./upower.nix
  ];
}
