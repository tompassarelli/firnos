#lang nisp

(raw-file
  (fn-set-rest (config lib pkgs)
    (att
      (config
        (mkif config.myConfig.modules.stylix.enable
          (att
            (environment.systemPackages
              (with-pkgs adwaita-icon-theme   ;; default GNOME icons (needed for nautilus)
                         gnome-themes-extra)) ;; includes Adwaita-dark theme
            ))))))
