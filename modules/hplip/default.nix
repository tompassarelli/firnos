{ lib, ... }:
{
  options.myConfig.modules.hplip.enable = lib.mkEnableOption "HP printer drivers";
  imports = [ ./hplip.nix ];
}
