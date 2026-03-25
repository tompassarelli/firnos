{ lib, ... }:
{
  options.myConfig.imv.enable = lib.mkEnableOption "imv image viewer";
  imports = [ ./imv.nix ];
}
