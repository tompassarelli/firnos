{ lib, ... }:
{
  options.myConfig.mako = {
    enable = lib.mkEnableOption "Mako notification daemon";
  };

  imports = [
    ./mako.nix
  ];
}
