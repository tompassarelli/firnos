#lang nisp

;; Included via imports = [ ./chrome.nix ] from default.rkt.
;; Sub-file declares only config (no options) — needs full { config, lib, pkgs, ... }: header.
(raw-file
  (fn-set-rest (config lib pkgs)
    (att
      (set 'config
        (mkif 'config.myConfig.modules.chrome.enable
          (att
            ;; Install Google Chrome
            (set 'environment.systemPackages (with-pkgs 'google-chrome))

            ;; Set as default browser if specified
            (set 'xdg.mime.defaultApplications
              (mkif 'config.myConfig.modules.chrome.default
                (att ("\"text/html\""                "google-chrome.desktop")
                     ("\"x-scheme-handler/http\""    "google-chrome.desktop")
                     ("\"x-scheme-handler/https\""   "google-chrome.desktop")
                     ("\"x-scheme-handler/about\""   "google-chrome.desktop")
                     ("\"x-scheme-handler/unknown\"" "google-chrome.desktop"))))))))))
