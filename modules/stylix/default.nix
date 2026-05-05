{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.stylix;
in
{
  options.myConfig.modules.stylix.enable = lib.mkEnableOption "Stylix base16 theming";
  options.myConfig.modules.stylix.chosenTheme = lib.mkOption {
    type = lib.types.str;
    description = "The base16 theme to use for styling (e.g., 'tokyo-night-dark', 'everforest-dark-hard')";
  };
  imports = [ ./fonts.nix ./xdg-portal.nix ./stylix.nix ];
}
