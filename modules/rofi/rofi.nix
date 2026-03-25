{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.rofi;
  username = config.myConfig.modules.users.username;
in
{
  config = lib.mkIf cfg.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============

    environment.systemPackages = with pkgs; [
      rofi-wayland  # it works, its fast

      # Helper script for workspace renaming with rofi dmenu mode
      (pkgs.writeShellScriptBin "rofi-rename-workspace" ''
        name=$(echo "" | rofi -dmenu -p "Rename Workspace")
        [ -n "$name" ] && niri msg action set-workspace-name "$name"
      '')

      # Helper script for workspace switching with rofi
      (pkgs.writeShellScriptBin "rofi-workspace-switcher" ''
        # Parse niri workspaces: "   1 "name"" or " * 2 "name"" format
        selected=$(niri msg workspaces | grep -E '^\s*\*?\s*[0-9]+' | \
          sed 's/^\s*\*\?\s*\([0-9]\+\)\s*\("\?\)\([^"]*\)\("\?\)/\1: \3/' | \
          sed 's/: $/: (unnamed)/' | \
          rofi -dmenu -p "Workspace" -i)

        [ -n "$selected" ] && {
          id=$(echo "$selected" | cut -d: -f1)
          niri msg action focus-workspace "$id"
        }
      '')
    ];

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = { config, ... }: {
      # Rofi configuration file
      xdg.configFile."rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/rofi/config.rasi";
    };
  };
}
