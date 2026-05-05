#lang nisp

(module-file modules ghostty
  (desc "Ghostty terminal")
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    (home-of-bare username
      (set programs.ghostty
        (att (enable #t)
             (package pkgs.unstable.ghostty)
             (settings
               (att (window-padding-x 6)
                    (window-padding-y 4)
                    (app-notifications "no-clipboard-copy"))))))))
