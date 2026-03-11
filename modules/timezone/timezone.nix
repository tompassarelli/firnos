{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.timezone;
in
{
  config = lib.mkIf cfg.enable {
    time.timeZone = "Asia/Bangkok";
  };
}
