{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.productivity;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.obsidian.enable = lib.mkDefault cfg.obsidian.enable;
    myConfig.modules.todoist.enable = lib.mkDefault cfg.todoist.enable;
    myConfig.modules.pomodoro.enable = lib.mkDefault cfg.pomodoro.enable;
    myConfig.modules.rustdesk.enable = lib.mkDefault cfg.rustdesk.enable;
    myConfig.modules.unrar.enable = lib.mkDefault cfg.unrar.enable;
    myConfig.modules.slack.enable = lib.mkDefault cfg.slack.enable;
    myConfig.modules.hugo.enable = lib.mkDefault cfg.hugo.enable;
    myConfig.modules.pandoc.enable = lib.mkDefault cfg.pandoc.enable;
  };
}
