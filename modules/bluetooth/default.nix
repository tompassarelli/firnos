{ lib, ... }:
{
  options.myConfig.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth configuration";
  };

  imports = [
    ./bluetooth.nix
  ];
}
