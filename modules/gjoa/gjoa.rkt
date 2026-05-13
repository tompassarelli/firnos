#lang nisp

;; Sibling file imported by default.nix. Installs the wrapped Gjoa Firefox
;; fork from the gjoa flake input — produces the .desktop file + icon
;; integration so drun/rofi/dock find it.
(raw-file
  (fn-set-rest (config lib pkgs inputs)
    (att
      (config
        (mkif config.myConfig.modules.gjoa.enable
          (att
            (environment.systemPackages
              (lst (nix-ident "inputs.gjoa.packages.${pkgs.stdenv.hostPlatform.system}.gjoa")))
            (xdg.mime.defaultApplications
              (mkif config.myConfig.modules.gjoa.default
                (att ("${\"text/html\"}" "gjoa.desktop")
                     ("${\"x-scheme-handler/http\"}" "gjoa.desktop")
                     ("${\"x-scheme-handler/https\"}" "gjoa.desktop")
                     ("${\"x-scheme-handler/about\"}" "gjoa.desktop")
                     ("${\"x-scheme-handler/unknown\"}" "gjoa.desktop"))))))))))
