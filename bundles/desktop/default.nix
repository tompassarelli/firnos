{ lib, ... }:
{
  options.myConfig.desktop = {
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
  };

  imports = [ ./desktop.nix ];
}
