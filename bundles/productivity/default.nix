{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.productivity;
in
{
  options.myConfig.bundles.productivity.enable = lib.mkEnableOption "personal productivity applications";
  options.myConfig.bundles.productivity.obsidian.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable obsidian";
  };
  options.myConfig.bundles.productivity.anytype.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable anytype";
  };
  options.myConfig.bundles.productivity.todoist.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable todoist";
  };
  options.myConfig.bundles.productivity.pomodoro.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable pomodoro";
  };
  options.myConfig.bundles.productivity.hugo.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable hugo";
  };
  options.myConfig.bundles.productivity.pandoc.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable pandoc";
  };
  options.myConfig.bundles.productivity.libreoffice.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable libreoffice";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.obsidian.enable = lib.mkDefault cfg.obsidian.enable;
    myConfig.modules.anytype.enable = lib.mkDefault cfg.anytype.enable;
    myConfig.modules.todoist.enable = lib.mkDefault cfg.todoist.enable;
    myConfig.modules.pomodoro.enable = lib.mkDefault cfg.pomodoro.enable;
    myConfig.modules.hugo.enable = lib.mkDefault cfg.hugo.enable;
    myConfig.modules.pandoc.enable = lib.mkDefault cfg.pandoc.enable;
    myConfig.modules.libreoffice.enable = lib.mkDefault cfg.libreoffice.enable;
  };
}
