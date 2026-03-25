{ lib, ... }:
{
  options.myConfig.modules.networking = {
    enable = lib.mkEnableOption "network configuration";
  };

  imports = [
    ./networking.nix
  ];
}