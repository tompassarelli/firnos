#lang nisp

;; browsers has nested .palefox.enable and .default options per browser —
;; doesn't fit sub-modules pattern. Done manually.
(bundle-file browsers
  (desc "web browsers")
  (option-attrs
    (firefox.enable          (mkopt #:type (t-bool) #:default #t #:desc "Enable Firefox"))
    (firefox.palefox.enable  (mkopt #:type (t-bool) #:default #f #:desc "Enable Palefox custom UI"))
    (firefox.default         (mkopt #:type (t-bool) #:default #t #:desc "Set Firefox as default browser"))
    (chrome.enable           (mkopt #:type (t-bool) #:default #f #:desc "Enable Chrome"))
    (chrome.default          (mkopt #:type (t-bool) #:default #f #:desc "Set Chrome as default browser"))
    (nyxt.enable             (mkopt #:type (t-bool) #:default #f #:desc "Enable Nyxt"))
    (nyxt.default            (mkopt #:type (t-bool) #:default #f #:desc "Set Nyxt as default browser"))
    (ladybird.enable         (mkopt #:type (t-bool) #:default #f #:desc "Enable Ladybird"))
    (qutebrowser.enable      (mkopt #:type (t-bool) #:default #f #:desc "Enable Qutebrowser"))
    (qutebrowser.default     (mkopt #:type (t-bool) #:default #f #:desc "Set Qutebrowser as default browser"))
    (zen-browser.enable      (mkopt #:type (t-bool) #:default #f #:desc "Enable Zen Browser"))
    (zen-browser.default     (mkopt #:type (t-bool) #:default #f #:desc "Set Zen Browser as default browser"))
    (librewolf.enable        (mkopt #:type (t-bool) #:default #f #:desc "Enable LibreWolf"))
    (librewolf.default       (mkopt #:type (t-bool) #:default #f #:desc "Set LibreWolf as default browser")))
  (config-body
    (set myConfig.modules.firefox.enable          (mkdefault cfg.firefox.enable))
    (set myConfig.modules.firefox.palefox.enable  (mkdefault cfg.firefox.palefox.enable))
    (set myConfig.modules.firefox.default         (mkdefault cfg.firefox.default))
    (set myConfig.modules.chrome.enable           (mkdefault cfg.chrome.enable))
    (set myConfig.modules.chrome.default          (mkdefault cfg.chrome.default))
    (set myConfig.modules.nyxt.enable             (mkdefault cfg.nyxt.enable))
    (set myConfig.modules.nyxt.default            (mkdefault cfg.nyxt.default))
    (set myConfig.modules.ladybird.enable         (mkdefault cfg.ladybird.enable))
    (set myConfig.modules.qutebrowser.enable      (mkdefault cfg.qutebrowser.enable))
    (set myConfig.modules.qutebrowser.default     (mkdefault cfg.qutebrowser.default))
    (set myConfig.modules.zen-browser.enable      (mkdefault cfg.zen-browser.enable))
    (set myConfig.modules.zen-browser.default     (mkdefault cfg.zen-browser.default))
    (set myConfig.modules.librewolf.enable        (mkdefault cfg.librewolf.enable))
    (set myConfig.modules.librewolf.default       (mkdefault cfg.librewolf.default))))
