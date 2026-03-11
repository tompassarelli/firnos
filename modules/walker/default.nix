{ lib, ... }:
{
  options.myConfig.walker = {
    enable = lib.mkEnableOption "Walker modern wayland app launcher";
  };

  imports = [
    ./walker.nix
  ];
}
