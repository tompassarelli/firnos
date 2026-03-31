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
    myConfig.modules.nautilus.enable = lib.mkDefault cfg.nautilus.enable;
    myConfig.modules.swaylock.enable = lib.mkDefault cfg.swaylock.enable;
    myConfig.modules.grim.enable = lib.mkDefault cfg.grim.enable;
    myConfig.modules.slurp.enable = lib.mkDefault cfg.slurp.enable;
    myConfig.modules.pavucontrol.enable = lib.mkDefault cfg.pavucontrol.enable;
    myConfig.modules.ffmpeg.enable = lib.mkDefault cfg.ffmpeg.enable;
    myConfig.modules.wf-recorder.enable = lib.mkDefault cfg.wf-recorder.enable;
    myConfig.modules.eyedropper.enable = lib.mkDefault cfg.eyedropper.enable;
  };
}
