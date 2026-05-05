{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.gtk;
  username = config.myConfig.modules.users.username;
  isDark = config.stylix.polarity == "dark";
in
{
  options.myConfig.modules.gtk.enable = lib.mkEnableOption "GTK theming configuration";
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = { config, ... }: let
      stylixGtkFont = (config.gtk.font.name + " ") + (toString config.gtk.font.size);
      stylixGtkTheme = config.gtk.theme.name;
    in
    {
      gtk.enable = true;
      home.packages = with pkgs; [ gsettings-desktop-schemas gtk3 ];
      xdg.configFile."gtk-3.0/settings.ini".text = lib.mkForce ''
        [Settings]
        gtk-application-prefer-dark-theme=${if isDark then "1" else "0"}
        gtk-font-name=${stylixGtkFont}
        gtk-theme-name=${stylixGtkTheme}
      '';
      xdg.configFile."gtk-4.0/settings.ini".text = lib.mkForce ''
        [Settings]
        gtk-application-prefer-dark-theme=${if isDark then "1" else "0"}
        gtk-font-name=${stylixGtkFont}
        gtk-theme-name=${stylixGtkTheme}
      '';
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = lib.mkForce (if isDark then "prefer-dark" else "prefer-light");
        };
      };
    };
  };
}
