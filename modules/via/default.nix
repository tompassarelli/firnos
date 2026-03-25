{ lib, ... }:
{
  options.myConfig.modules.via = {
    enable = lib.mkEnableOption "VIA keyboard configurator support";
  };

  imports = [
    ./via.nix
  ];
}
