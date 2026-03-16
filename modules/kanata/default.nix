{ lib, ... }:
{
  options.myConfig.kanata = {
    enable = lib.mkEnableOption "Kanata keyboard remapping";
    capsLockEscCtrl = lib.mkEnableOption "Caps Lock as Tap=Esc, Hold=Ctrl";
    spacebarSymbols = lib.mkEnableOption "Spacebar as Tap=Space, Hold=Symbols layer";
    devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Input device paths for kanata to capture. Find yours with: ls /dev/input/by-id/";
    };
  };

  imports = [
    ./kanata.nix
  ];
}
