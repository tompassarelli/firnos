{ config, lib, ... }:

let
  cfg = config.myConfig.look-and-feel;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.gtk.enable = lib.mkDefault cfg.gtk.enable;
    myConfig.styling.enable = lib.mkDefault cfg.styling.enable;
    myConfig.theming.enable = lib.mkDefault cfg.theming.enable;
    myConfig.theme-switcher.enable = lib.mkDefault cfg.theme-switcher.enable;
    myConfig.nerd-fonts.enable = lib.mkDefault cfg.nerd-fonts.enable;
  };
}
