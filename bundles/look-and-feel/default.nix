{ lib, ... }:
{
  options.myConfig.look-and-feel = {
    enable = lib.mkEnableOption "visual theming stack";
    gtk.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable gtk"; };
    styling.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable styling"; };
    theming.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable theming"; };
    theme-switcher.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable theme-switcher"; };
    nerd-fonts.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable nerd-fonts"; };
  };

  imports = [ ./look-and-feel.nix ];
}
