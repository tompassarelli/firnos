{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.communication;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.discord.enable = lib.mkDefault cfg.discord.enable;
    myConfig.modules.zoom.enable = lib.mkDefault cfg.zoom.enable;
    myConfig.modules.slack.enable = lib.mkDefault cfg.slack.enable;
    myConfig.modules.mail.enable = lib.mkDefault cfg.mail.enable;
  };
}
