{ lib, ... }:
{
  options.myConfig.modules.wl-gammarelay = {
    enable = lib.mkEnableOption "Wayland gamma/temperature control";
  };

  imports = [
    ./wl-gammarelay.nix
  ];
}
