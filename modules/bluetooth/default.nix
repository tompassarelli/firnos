{ lib, ... }:
{
  options.myConfig.modules.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth configuration";
  };

  imports = [
    ./bluetooth.nix
  ];
}
