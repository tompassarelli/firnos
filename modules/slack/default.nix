{ lib, ... }:
{
  options.myConfig.slack.enable = lib.mkEnableOption "Slack messaging";
  imports = [ ./slack.nix ];
}
