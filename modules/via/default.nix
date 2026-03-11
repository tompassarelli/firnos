{ lib, ... }:
{
  options.myConfig.via = {
    enable = lib.mkEnableOption "VIA keyboard configurator support";
  };

  imports = [
    ./via.nix
  ];
}
