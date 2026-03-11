{ lib, ... }:
{
  options.myConfig.gtk = {
    enable = lib.mkEnableOption "GTK theming configuration";
  };

  imports = [
    ./gtk.nix
  ];
}
