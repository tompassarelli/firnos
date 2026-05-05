#lang nisp

(module-file modules rofi
  (desc "Rofi application launcher")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    ;; ============ SYSTEM-LEVEL CONFIGURATION ============
    (set 'environment.systemPackages
      (with-do 'pkgs
        (lst
          'rofi  ;; rofi-wayland merged into rofi in 25.11

          ;; Helper script for workspace renaming with rofi dmenu mode
          (call 'pkgs.writeShellScriptBin "rofi-rename-workspace"
            (ms "name=$(echo \"\" | rofi -dmenu -p \"Rename Workspace\")"
                "[ -n \"$name\" ] && niri msg action set-workspace-name \"$name\""))

          ;; Helper script for workspace switching with rofi
          (call 'pkgs.writeShellScriptBin "rofi-workspace-switcher"
            (ms "# Parse niri workspaces: \"   1 \"name\"\" or \" * 2 \"name\"\" format"
                "selected=$(niri msg workspaces | grep -E '^\\s*\\*?\\s*[0-9]+' | \\"
                "  sed 's/^\\s*\\*\\?\\s*\\([0-9]\\+\\)\\s*\\(\"\\?\\)\\([^\"]*\\)\\(\"\\?\\)/\\1: \\3/' | \\"
                "  sed 's/: $/: (unnamed)/' | \\"
                "  rofi -dmenu -p \"Workspace\" -i)"
                ""
                "[ -n \"$selected\" ] && {"
                "  id=$(echo \"$selected\" | cut -d: -f1)"
                "  niri msg action focus-workspace \"$id\""
                "}")))))

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of 'username
      ;; Rofi configuration file
      (set "xdg.configFile.\"rofi/config.rasi\".source"
        (call 'config.lib.file.mkOutOfStoreSymlink
              (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/rofi/config.rasi"))))))
