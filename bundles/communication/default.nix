{ lib, ... }:
{
  options.myConfig.bundles.communication = {
    enable = lib.mkEnableOption "communication applications";
    discord.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Discord"; };
    zoom.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Zoom"; };
    slack.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Slack"; };
    mail.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable mail"; };
  };

  imports = [ ./communication.nix ];
}
