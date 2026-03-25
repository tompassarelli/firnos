{ lib, ... }:
{
  options.myConfig.fwupd.enable = lib.mkEnableOption "fwupd firmware updater";
  imports = [ ./fwupd.nix ];
}
