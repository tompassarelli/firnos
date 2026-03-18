{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.sqlcmd;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sqlcmd ];
  };
}
