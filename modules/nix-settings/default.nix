{ lib, ... }:
{
  options.myConfig.modules.nix-settings = {
    enable = lib.mkEnableOption "Nix configuration and package settings";
  };

  imports = [
    ./nix-settings.nix
  ];
}