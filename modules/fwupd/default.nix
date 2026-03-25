{ lib, ... }:
{
  options.myConfig.modules.fwupd.enable = lib.mkEnableOption "fwupd firmware updater";
  imports = [ ./fwupd.nix ];
}
