{ lib, ... }:
{
  options.myConfig.hplip.enable = lib.mkEnableOption "HP printer drivers";
  imports = [ ./hplip.nix ];
}
