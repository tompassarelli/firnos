#lang nisp

(module-file modules nyxt
  (desc "Enable Nyxt browser")
  (option-attrs
    ('default (mkopt #:type (t-bool) #:default #f
                    #:desc "Set Nyxt as the default browser via MIME types")))
  (raw-body
    (imports (p "./nyxt.nix"))))
