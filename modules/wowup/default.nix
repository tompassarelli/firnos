{ lib, ... }:
{
  options.myConfig.wowup.enable = lib.mkEnableOption "WowUp-CF addon manager";
  imports = [ ./wowup.nix ];
}
