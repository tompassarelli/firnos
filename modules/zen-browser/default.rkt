#lang nisp

(module-file modules zen-browser
  (desc "Enable Zen Browser")
  (option-attrs
    ('default
      (mkopt #:type (t-bool) #:default #f
             #:desc "Set Zen Browser as the default browser via MIME types")))
  (raw-body
    (imports (p "./zen-browser.nix"))))
