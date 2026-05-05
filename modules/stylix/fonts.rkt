#lang nisp

(raw-file
  (fn-set-rest (config lib)
    (att
      (config
        (mkif config.myConfig.modules.stylix.enable
          (att
            ;; Font configuration
            (fonts.fontconfig.enable #t)))))))
