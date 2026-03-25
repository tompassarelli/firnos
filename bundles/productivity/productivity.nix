{ config, lib, ... }:

let
  cfg = config.myConfig.productivity;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.obsidian.enable = lib.mkDefault cfg.obsidian.enable;
    myConfig.todoist.enable = lib.mkDefault cfg.todoist.enable;
    myConfig.pomodoro.enable = lib.mkDefault cfg.pomodoro.enable;
    myConfig.rustdesk.enable = lib.mkDefault cfg.rustdesk.enable;
    myConfig.unrar.enable = lib.mkDefault cfg.unrar.enable;
    myConfig.slack.enable = lib.mkDefault cfg.slack.enable;
    myConfig.hugo.enable = lib.mkDefault cfg.hugo.enable;
    myConfig.pandoc.enable = lib.mkDefault cfg.pandoc.enable;
  };
}
