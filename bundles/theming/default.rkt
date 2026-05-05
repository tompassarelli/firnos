#lang nisp

;; stylix.chosenTheme is a STR option, not bool — needs explicit option-attrs.
(bundle-file theming
  (desc "visual theming stack")
  (option-attrs
    (gtk.enable             (mkopt #:type (t-bool) #:default #t #:desc "Enable GTK"))
    (styling.enable         (mkopt #:type (t-bool) #:default #t #:desc "Enable Stylix styling"))
    (stylix.enable          (mkopt #:type (t-bool) #:default #t #:desc "Enable Stylix base16"))
    (stylix.chosenTheme     (mkopt #:type (t-str)  #:default "tokyo-night-dark" #:desc "Base16 theme name"))
    (theme-switcher.enable  (mkopt #:type (t-bool) #:default #t #:desc "Enable theme switcher"))
    (nerd-fonts.enable      (mkopt #:type (t-bool) #:default #t #:desc "Enable Nerd Fonts")))
  (config-body
    (set myConfig.modules.gtk.enable             (mkdefault 'cfg.gtk.enable))
    (set myConfig.modules.styling.enable         (mkdefault 'cfg.styling.enable))
    (set myConfig.modules.stylix.enable          (mkdefault 'cfg.stylix.enable))
    (set myConfig.modules.stylix.chosenTheme     (mkdefault 'cfg.stylix.chosenTheme))
    (set myConfig.modules.theme-switcher.enable  (mkdefault 'cfg.theme-switcher.enable))
    (set myConfig.modules.nerd-fonts.enable      (mkdefault 'cfg.nerd-fonts.enable))))
