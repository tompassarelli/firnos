{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.gtk;
  username = config.myConfig.users.username;
  # Get polarity from system-level stylix config
  isDark = config.stylix.polarity == "dark";
in
{
  config = lib.mkIf cfg.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============
    # (None needed - gtk is configured via home-manager)

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = { config, ... }:
    let
      # Get Stylix's GTK settings
      stylixGtkFont = config.gtk.font.name + " " + toString config.gtk.font.size;
      stylixGtkTheme = config.gtk.theme.name;
    in {
      # Let Stylix handle base GTK config
      gtk.enable = true;

      # Add GTK packages and gsettings schemas to fix GLib-GIO warnings
      home.packages = with pkgs; [
        gsettings-desktop-schemas
        gtk3
      ];

      # Override the settings.ini files to add dark mode preference
      # We read Stylix's values and add our dark mode setting
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

      # Set GTK color scheme preference for modern apps
      # Override Stylix's default setting dynamically based on polarity
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = lib.mkForce (
            if isDark then "prefer-dark" else "prefer-light"
          );
        };
      };
    };
  };
}
