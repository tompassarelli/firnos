#lang nisp

;; This file is included via imports = [ ./qutebrowser.nix ] from default.nix.
;; It does not declare options; it only provides the config block.
(raw-file
  (fn-set-rest (config lib pkgs)
    (att
      (set config
        (mkif config.myConfig.modules.qutebrowser.enable
          (att
            (set environment.systemPackages (with-pkgs qutebrowser))

            (set xdg.mime.defaultApplications
              (mkif config.myConfig.modules.qutebrowser.default
                (att ("\"text/html\""                "org.qutebrowser.qutebrowser.desktop")
                     ("\"x-scheme-handler/http\""    "org.qutebrowser.qutebrowser.desktop")
                     ("\"x-scheme-handler/https\""   "org.qutebrowser.qutebrowser.desktop")
                     ("\"x-scheme-handler/about\""   "org.qutebrowser.qutebrowser.desktop")
                     ("\"x-scheme-handler/unknown\"" "org.qutebrowser.qutebrowser.desktop"))))))))))
