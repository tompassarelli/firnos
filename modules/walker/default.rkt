#lang nisp

(module-file modules walker
  (desc "Walker modern wayland app launcher")
  (extra-args inputs)
  (lets ([username config.myConfig.modules.users.username])
        )
  (config-body
    ;; ============ SYSTEM-LEVEL CONFIGURATION ============
    (set environment.systemPackages
      (lst
        ;; Helper script for workspace renaming with walker dmenu mode
        (call pkgs.writeShellScriptBin "walker-rename-workspace"
          (ms "name=$(echo \"\" | walker --dmenu)"
              "[ -n \"$name\" ] && niri msg action set-workspace-name \"$name\""))))

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of username
      ;; Import walker home-manager module
      (set imports (lst inputs.walker.homeManagerModules.default))

      ;; Elephant desktop applications config - ensure proper Wayland env vars
      (set home.file
        (att ("${\".config/elephant/desktopapplications.toml\"}"
              (att (text
                    (ms "# Force proper Wayland env vars when launching apps (fixes Steam on niri)"
                        "launch_prefix = \"env WAYLAND_DISPLAY=wayland-1 DISPLAY=:0\""))))))

      ;; Enable walker and elephant with runAsService
      (set programs.walker
        (att (enable #t)
             (runAsService #t)
             ;; Configure dmenu for workspace renaming and applications launcher
             (config
               (att (hide_quick_activation #t)
                    (providers
                      (att (default (lst "desktopapplications" "calc" "windows"))
                           (empty (lst "desktopapplications"))))
                    (keybinds
                      (att (quick_activate (lst "alt a" "alt s" "alt d" "alt f"
                                                "alt j" "alt k" "alt l" "alt semicolon"))
                           (next (lst "Down" "ctrl j"))
                           (previous (lst "Up" "ctrl k"))))
                    (builtins.applications
                      (att (actions
                            (att (start
                                  (att (activation_mode
                                        (att (type "key")
                                             (key "Return"))))))) ))
                    (builtins.windows
                      (att (actions
                            (lst (att (action "focus")
                                      (bind "Return")
                                      (default #t))))))
                    (builtins.dmenu
                      (att (hidden #f)
                           (weight 5)
                           (name "dmenu")
                           (placeholder "Rename Workspace")
                           (switcher_only #f)
                           (show_icon_when_single #t))))))))))
