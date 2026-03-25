{ lib, ... }:
{
  options.myConfig.bundles.theming = {
    enable = lib.mkEnableOption "visual theming stack";
    gtk.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GTK"; };
    styling.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Stylix styling"; };
    stylix.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Stylix base16"; };
    theme-switcher.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable theme switcher"; };
    nerd-fonts.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Nerd Fonts"; };
  };

  imports = [ ./theming.nix ];
}
