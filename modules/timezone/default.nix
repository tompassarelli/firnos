{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.timezone;
in
{
  options.myConfig.modules.timezone = {
    enable = lib.mkEnableOption "timezone configuration";
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = "Asia/Bangkok";
  };
}
