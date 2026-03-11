{ lib, ... }:
{
  options.myConfig.ironbar = {
    enable = lib.mkEnableOption "Ironbar status bar for Wayland";
  };

  imports = [
    ./ironbar.nix
  ];
}
