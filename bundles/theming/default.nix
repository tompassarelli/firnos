{ config, lib, ... }:
let cfg = config.myConfig.bundles.theming;
in {
  options.myConfig.bundles.theming = {
    enable = lib.mkEnableOption "visual theming stack";
    gtk.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GTK"; };
    styling.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Stylix styling"; };
    stylix.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Stylix base16"; };
    stylix.chosenTheme = lib.mkOption { type = lib.types.str; default = "tokyo-night-dark"; description = "Base16 theme name"; };
    theme-switcher.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable theme switcher"; };
    nerd-fonts.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Nerd Fonts"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.gtk.enable = lib.mkDefault cfg.gtk.enable;
    myConfig.modules.styling.enable = lib.mkDefault cfg.styling.enable;
    myConfig.modules.stylix.enable = lib.mkDefault cfg.stylix.enable;
    myConfig.modules.stylix.chosenTheme = lib.mkDefault cfg.stylix.chosenTheme;
    myConfig.modules.theme-switcher.enable = lib.mkDefault cfg.theme-switcher.enable;
    myConfig.modules.nerd-fonts.enable = lib.mkDefault cfg.nerd-fonts.enable;
  };
}
