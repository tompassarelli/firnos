#lang nisp

;; Included via imports = [ ./firefox.nix ] from default.rkt.
(raw-file
  (fn-set-rest (config lib)
    (att
      (set 'config
        (mkif 'config.myConfig.modules.firefox.enable
          (att
            (set 'programs.firefox.enable #t)

            ;; Set as default browser if specified
            (set 'xdg.mime.defaultApplications
              (mkif 'config.myConfig.modules.firefox.default
                (att ("\"text/html\""                "firefox.desktop")
                     ("\"x-scheme-handler/http\""    "firefox.desktop")
                     ("\"x-scheme-handler/https\""   "firefox.desktop")
                     ("\"x-scheme-handler/about\""   "firefox.desktop")
                     ("\"x-scheme-handler/unknown\"" "firefox.desktop"))))))))))
