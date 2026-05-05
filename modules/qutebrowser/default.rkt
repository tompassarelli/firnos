#lang nisp

(module-file modules qutebrowser
  (desc "Enable Qutebrowser")
  (option-attrs
    (default (mkopt #:type (t-bool) #:default #f
                    #:desc "Set Qutebrowser as the default browser via MIME types")))
  (raw-body
    (imports (p "./qutebrowser.nix"))))
