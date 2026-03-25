{ lib, ... }:
{
  options.myConfig.modules.nautilus.enable = lib.mkEnableOption "Nautilus file manager";
  imports = [ ./nautilus.nix ];
}
