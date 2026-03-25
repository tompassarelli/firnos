{ lib, ... }:
{
  options.myConfig.modules.mako = {
    enable = lib.mkEnableOption "Mako notification daemon";
  };

  imports = [
    ./mako.nix
  ];
}
