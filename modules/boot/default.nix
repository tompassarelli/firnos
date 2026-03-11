{ lib, ... }:
{
  options.myConfig.boot = {
    enable = lib.mkEnableOption "boot configuration";
  };

  imports = [
    ./boot.nix
  ];
}
