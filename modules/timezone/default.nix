{ lib, ... }:
{
  options.myConfig.modules.timezone = {
    enable = lib.mkEnableOption "timezone configuration";
  };

  imports = [
    ./timezone.nix
  ];
}