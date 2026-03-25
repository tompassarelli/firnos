{ lib, ... }:
{
  options.myConfig.todoist.enable = lib.mkEnableOption "Todoist task manager";
  imports = [ ./todoist.nix ];
}
