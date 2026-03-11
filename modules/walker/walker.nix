{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myConfig.walker;
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf cfg.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============

    environment.systemPackages = with pkgs; [
      # Helper script for workspace renaming with walker dmenu mode
      (pkgs.writeShellScriptBin "walker-rename-workspace" ''
        name=$(echo "" | walker --dmenu)
        [ -n "$name" ] && niri msg action set-workspace-name "$name"
      '')
    ];

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = { config, ... }: {
      # Import walker home-manager module
      imports = [ inputs.walker.homeManagerModules.default ];

      # Elephant desktop applications config - ensure proper Wayland env vars
      home.file.".config/elephant/desktopapplications.toml".text = ''
        # Force proper Wayland env vars when launching apps (fixes Steam on niri)
        launch_prefix = "env WAYLAND_DISPLAY=wayland-1 DISPLAY=:0"
      '';

      # Enable walker and elephant with runAsService
      programs.walker = {
        enable = true;
        runAsService = true;

        # Configure dmenu for workspace renaming and applications launcher
        config = {
          hide_quick_activation = true;

          providers = {
            default = ["desktopapplications" "calc" "windows"];
            empty = ["desktopapplications"];
          };

          keybinds = {
            quick_activate = ["alt a" "alt s" "alt d" "alt f" "alt j" "alt k" "alt l" "alt semicolon"];
            next = ["Down" "ctrl j"];
            previous = ["Up" "ctrl k"];
          };

          builtins.applications = {
            actions = {
              start = {
                activation_mode = {
                  type = "key";
                  key = "Return";
                };
              };
            };
          };

          builtins.windows = {
            actions = [
              {
                action = "focus";
                bind = "Return";
                default = true;
              }
            ];
          };

          builtins.dmenu = {
            hidden = false;
            weight = 5;
            name = "dmenu";
            placeholder = "Rename Workspace";
            switcher_only = false;
            show_icon_when_single = true;
          };
        };
      };
    };
  };
}
