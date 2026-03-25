{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.slack.enable = lib.mkEnableOption "Slack messaging";

  config = lib.mkIf config.myConfig.modules.slack.enable {
    environment.systemPackages = [ pkgs.slack ];
  };
}
