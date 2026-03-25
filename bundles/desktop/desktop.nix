{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.desktop;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.niri.enable = lib.mkDefault cfg.niri.enable;
    myConfig.modules.upower.enable = lib.mkDefault cfg.upower.enable;
    myConfig.modules.rofi.enable = lib.mkDefault cfg.rofi.enable;
    myConfig.modules.quickshell.enable = lib.mkDefault cfg.quickshell.enable;
    myConfig.modules.wl-clipboard.enable = lib.mkDefault cfg.wl-clipboard.enable;
    myConfig.modules.brightnessctl.enable = lib.mkDefault cfg.brightnessctl.enable;
    myConfig.modules.libnotify.enable = lib.mkDefault cfg.libnotify.enable;
    myConfig.modules.wl-gammarelay.enable = lib.mkDefault cfg.wl-gammarelay.enable;
    myConfig.modules.mako.enable = lib.mkDefault cfg.mako.enable;
  };
}
