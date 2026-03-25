{ lib, ... }:
{
  options.myConfig.modules.todoist.enable = lib.mkEnableOption "Todoist task manager";
  imports = [ ./todoist.nix ];
}
