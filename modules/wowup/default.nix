{ lib, ... }:
{
  options.myConfig.modules.wowup.enable = lib.mkEnableOption "WowUp-CF addon manager";
  imports = [ ./wowup.nix ];
}
