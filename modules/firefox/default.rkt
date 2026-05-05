#lang nisp

(module-file modules firefox
  (desc "Enable Firefox browser")
  (option-attrs
    (palefox.enable (mkenable "Enable Palefox (Firefox with custom UI styling)"))
    (default (mkopt #:type (t-bool) #:default #t
                    #:desc "Set Firefox as the default browser via MIME types")))
  (raw-body
    (imports "./firefox.nix" "./palefox.nix")))
