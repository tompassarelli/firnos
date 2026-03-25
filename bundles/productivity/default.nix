{ lib, ... }:
{
  options.myConfig.bundles.productivity = {
    enable = lib.mkEnableOption "personal productivity applications";
    obsidian.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Obsidian"; };
    todoist.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Todoist"; };
    pomodoro.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Pomodoro timer"; };
    rustdesk.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable RustDesk"; };
    unrar.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable unrar"; };
    slack.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Slack"; };
    hugo.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Hugo"; };
    pandoc.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Pandoc"; };
  };

  imports = [
    ./productivity.nix
  ];
}
