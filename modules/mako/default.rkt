#lang nisp

(module-file modules mako
  (desc "Mako notification daemon")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    ;; ============ SYSTEM-LEVEL CONFIGURATION ============
    ;; (None needed - mako is installed via home-manager)

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of-bare 'username
      (set services.mako
        (att (enable #t)
             (settings
               (att (default-timeout 0)   ;; Don't auto-dismiss notifications
                    (icons 0)             ;; Hide app icons
                    ;; Claude Code notifications - no auto-dismiss
                    ("\"app-name=kitty\"" (att (default-timeout 0)))
                    ;; Suppress Spotify track change notifications
                    ("\"app-name=Spotify\"" (att (invisible 1))))))))))
