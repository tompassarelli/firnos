{ lib, ... }:
{
  options.myConfig.modules.fish = {
    enable = lib.mkEnableOption "Fish shell configuration";
  };

  imports = [
    ./fish.nix
  ];
}
