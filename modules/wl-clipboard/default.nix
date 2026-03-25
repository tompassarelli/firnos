{ lib, ... }:
{
  options.myConfig.modules.wl-clipboard = {
    enable = lib.mkEnableOption "Wayland clipboard utilities";
  };

  imports = [
    ./wl-clipboard.nix
  ];
}
