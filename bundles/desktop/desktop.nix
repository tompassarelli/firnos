{ config, lib, ... }:

let
  cfg = config.myConfig.desktop;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.niri.enable = lib.mkDefault cfg.niri.enable;
    myConfig.upower.enable = lib.mkDefault cfg.upower.enable;
    myConfig.rofi.enable = lib.mkDefault cfg.rofi.enable;
    myConfig.quickshell.enable = lib.mkDefault cfg.quickshell.enable;
    myConfig.wl-clipboard.enable = lib.mkDefault cfg.wl-clipboard.enable;
    myConfig.brightnessctl.enable = lib.mkDefault cfg.brightnessctl.enable;
    myConfig.libnotify.enable = lib.mkDefault cfg.libnotify.enable;
    myConfig.wl-gammarelay.enable = lib.mkDefault cfg.wl-gammarelay.enable;
    myConfig.mako.enable = lib.mkDefault cfg.mako.enable;
  };
}
