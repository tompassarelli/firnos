{ lib, ... }:
{
  options.myConfig.bundles.desktop = {
    enable = lib.mkEnableOption "Wayland desktop environment";
    niri.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable niri"; };
    upower.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable upower"; };
    rofi.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable rofi"; };
    quickshell.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable quickshell"; };
    wl-clipboard.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable wl-clipboard"; };
    brightnessctl.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable brightnessctl"; };
    libnotify.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable libnotify"; };
    wl-gammarelay.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable wl-gammarelay"; };
    mako.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable mako"; };
    nautilus.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Nautilus"; };
    swaylock.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable swaylock"; };
    grim.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable grim"; };
    slurp.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable slurp"; };
    pavucontrol.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable pavucontrol"; };
    ffmpeg.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable FFmpeg"; };
    wf-recorder.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable wf-recorder"; };
    eyedropper.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Eyedropper"; };
  };

  imports = [ ./desktop.nix ];
}
