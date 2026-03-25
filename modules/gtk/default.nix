{ lib, ... }:
{
  options.myConfig.modules.gtk = {
    enable = lib.mkEnableOption "GTK theming configuration";
  };

  imports = [
    ./gtk.nix
  ];
}
