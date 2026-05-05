{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.communication;
in
{
  options.myConfig.bundles.communication.enable = lib.mkEnableOption "communication applications";
  options.myConfig.bundles.communication.discord.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable discord";
  };
  options.myConfig.bundles.communication.zoom.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable zoom";
  };
  options.myConfig.bundles.communication.slack.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable slack";
  };
  options.myConfig.bundles.communication.mail.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable mail";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.discord.enable = lib.mkDefault cfg.discord.enable;
    myConfig.modules.zoom.enable = lib.mkDefault cfg.zoom.enable;
    myConfig.modules.slack.enable = lib.mkDefault cfg.slack.enable;
    myConfig.modules.mail.enable = lib.mkDefault cfg.mail.enable;
  };
}
