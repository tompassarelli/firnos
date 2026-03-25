{ lib, ... }:
{
  options.myConfig.nautilus.enable = lib.mkEnableOption "Nautilus file manager";
  imports = [ ./nautilus.nix ];
}
