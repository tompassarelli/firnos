{ lib, ... }:
{
  options.myConfig.modules.slack.enable = lib.mkEnableOption "Slack messaging";
  imports = [ ./slack.nix ];
}
