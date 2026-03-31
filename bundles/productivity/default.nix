{ config, lib, ... }:
let cfg = config.myConfig.bundles.productivity;
in {
  options.myConfig.bundles.productivity = {
    enable = lib.mkEnableOption "personal productivity applications";
    obsidian.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Obsidian"; };
    todoist.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Todoist"; };
    pomodoro.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Pomodoro timer"; };
    hugo.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Hugo"; };
    pandoc.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Pandoc"; };
    libreoffice.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable LibreOffice"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.obsidian.enable = lib.mkDefault cfg.obsidian.enable;
    myConfig.modules.todoist.enable = lib.mkDefault cfg.todoist.enable;
    myConfig.modules.pomodoro.enable = lib.mkDefault cfg.pomodoro.enable;
    myConfig.modules.hugo.enable = lib.mkDefault cfg.hugo.enable;
    myConfig.modules.pandoc.enable = lib.mkDefault cfg.pandoc.enable;
    myConfig.modules.libreoffice.enable = lib.mkDefault cfg.libreoffice.enable;
  };
}
