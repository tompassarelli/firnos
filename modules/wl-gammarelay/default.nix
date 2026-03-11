{ lib, ... }:
{
  options.myConfig.wl-gammarelay = {
    enable = lib.mkEnableOption "Wayland gamma/temperature control";
  };

  imports = [
    ./wl-gammarelay.nix
  ];
}
