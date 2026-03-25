{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.slack.enable {
    environment.systemPackages = [ pkgs.slack ];
  };
}
