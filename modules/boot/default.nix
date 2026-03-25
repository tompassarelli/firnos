{ lib, ... }:
{
  options.myConfig.modules.boot = {
    enable = lib.mkEnableOption "boot configuration";
  };

  imports = [
    ./boot.nix
  ];
}
