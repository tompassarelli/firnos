{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.theming;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.gtk.enable = lib.mkDefault cfg.gtk.enable;
    myConfig.modules.styling.enable = lib.mkDefault cfg.styling.enable;
    myConfig.modules.stylix.enable = lib.mkDefault cfg.stylix.enable;
    myConfig.modules.theme-switcher.enable = lib.mkDefault cfg.theme-switcher.enable;
    myConfig.modules.nerd-fonts.enable = lib.mkDefault cfg.nerd-fonts.enable;
  };
}
