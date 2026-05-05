{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.desktop;
in
{
  options.myConfig.bundles.desktop.enable = lib.mkEnableOption "Wayland desktop environment";
  options.myConfig.bundles.desktop.niri.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable niri";
  };
  options.myConfig.bundles.desktop.upower.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable upower";
  };
  options.myConfig.bundles.desktop.rofi.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable rofi";
  };
  options.myConfig.bundles.desktop.quickshell.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable quickshell";
  };
  options.myConfig.bundles.desktop.wl-clipboard.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable wl-clipboard";
  };
  options.myConfig.bundles.desktop.brightnessctl.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable brightnessctl";
  };
  options.myConfig.bundles.desktop.libnotify.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable libnotify";
  };
  options.myConfig.bundles.desktop.wl-gammarelay.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable wl-gammarelay";
  };
  options.myConfig.bundles.desktop.mako.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable mako";
  };
  options.myConfig.bundles.desktop.nautilus.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable nautilus";
  };
  options.myConfig.bundles.desktop.swaylock.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable swaylock";
  };
  options.myConfig.bundles.desktop.grim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable grim";
  };
  options.myConfig.bundles.desktop.slurp.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable slurp";
  };
  options.myConfig.bundles.desktop.pavucontrol.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable pavucontrol";
  };
  options.myConfig.bundles.desktop.ffmpeg.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable ffmpeg";
  };
  options.myConfig.bundles.desktop.wf-recorder.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable wf-recorder";
  };
  options.myConfig.bundles.desktop.eyedropper.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable eyedropper";
  };
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
