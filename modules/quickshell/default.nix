{ lib, ... }:
{
  options.myConfig.modules.quickshell = {
    enable = lib.mkEnableOption "Quickshell (Qt6/QML) status bar";
  };

  imports = [
    ./quickshell.nix
  ];
}
