{ lib, ... }:
{
  options.myConfig.networking = {
    enable = lib.mkEnableOption "network configuration";
  };

  imports = [
    ./networking.nix
  ];
}