#lang nisp

;; Sibling file imported by default.nix.
;; Emits as a NixOS submodule that sets system packages and (optionally)
;; xdg.mime defaults when zen-browser is enabled.
(raw-file
  (fn-set-rest (config lib pkgs inputs)
    (att
      ('config
        (mkif 'config.myConfig.modules.zen-browser.enable
          (att
            ('environment.systemPackages
              (lst (nix-ident "inputs.zen-browser.packages.${pkgs.system}.default")))
            ('xdg.mime.defaultApplications
              (mkif 'config.myConfig.modules.zen-browser.default
                (att ("${\"text/html\"}" "zen.desktop")
                     ("${\"x-scheme-handler/http\"}" "zen.desktop")
                     ("${\"x-scheme-handler/https\"}" "zen.desktop")
                     ("${\"x-scheme-handler/about\"}" "zen.desktop")
                     ("${\"x-scheme-handler/unknown\"}" "zen.desktop"))))))))))
