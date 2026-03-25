{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.slack.enable {
    environment.systemPackages = [ pkgs.slack ];
  };
}
