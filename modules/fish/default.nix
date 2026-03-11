{ lib, ... }:
{
  options.myConfig.fish = {
    enable = lib.mkEnableOption "Fish shell configuration";
  };

  imports = [
    ./fish.nix
  ];
}
