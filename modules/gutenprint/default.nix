{ lib, ... }:
{
  options.myConfig.gutenprint.enable = lib.mkEnableOption "Gutenprint printer drivers";
  imports = [ ./gutenprint.nix ];
}
