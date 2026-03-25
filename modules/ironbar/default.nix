{ lib, ... }:
{
  options.myConfig.modules.ironbar = {
    enable = lib.mkEnableOption "Ironbar status bar for Wayland";
  };

  imports = [
    ./ironbar.nix
  ];
}
