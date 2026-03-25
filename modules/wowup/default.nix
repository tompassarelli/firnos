{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.wowup.enable = lib.mkEnableOption "WowUp-CF addon manager";

  config = lib.mkIf config.myConfig.modules.wowup.enable {
    environment.systemPackages = [ pkgs.wowup-cf ];
  };
}
