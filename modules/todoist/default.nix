{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.todoist.enable = lib.mkEnableOption "Todoist task manager";

  config = lib.mkIf config.myConfig.modules.todoist.enable {
    environment.systemPackages = [ pkgs.todoist-electron ];
  };
}
