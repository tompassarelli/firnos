{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.timezone.enable = lib.mkEnableOption "timezone configuration";
  config = lib.mkIf config.myConfig.modules.timezone.enable {
    time.timeZone = "Asia/Bangkok";
  };
}
