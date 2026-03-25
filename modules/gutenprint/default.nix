{ lib, ... }:
{
  options.myConfig.modules.gutenprint.enable = lib.mkEnableOption "Gutenprint printer drivers";
  imports = [ ./gutenprint.nix ];
}
