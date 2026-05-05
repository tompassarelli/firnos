#lang nisp

(module-file modules librewolf
  (desc "Enable LibreWolf browser")
  (option-attrs
    (default (mkopt #:type (t-bool)
                    #:default #f
                    #:desc "Set LibreWolf as the default browser via MIME types")))
  (raw-body (imports (p "./librewolf.nix"))))
