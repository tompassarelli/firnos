{ lib, ... }:
{
  options.myConfig.modules.imv.enable = lib.mkEnableOption "imv image viewer";
  imports = [ ./imv.nix ];
}
