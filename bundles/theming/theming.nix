{ config, lib, ... }:

let
  cfg = config.myConfig.theming;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.gtk.enable = lib.mkDefault cfg.gtk.enable;
    myConfig.styling.enable = lib.mkDefault cfg.styling.enable;
    myConfig.stylix.enable = lib.mkDefault cfg.stylix.enable;
    myConfig.theme-switcher.enable = lib.mkDefault cfg.theme-switcher.enable;
    myConfig.nerd-fonts.enable = lib.mkDefault cfg.nerd-fonts.enable;
  };
}
