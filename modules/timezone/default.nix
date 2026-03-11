{ lib, ... }:
{
  options.myConfig.timezone = {
    enable = lib.mkEnableOption "timezone configuration";
  };

  imports = [
    ./timezone.nix
  ];
}