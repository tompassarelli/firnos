#lang nisp

(module-file modules gjoa
  (desc "Gjoa — a Firefox fork. Wrapped via wrapFirefox; appears in launchers/drun.")
  (option-attrs
    (default
      (mkopt #:type (t-bool) #:default #f
             #:desc "Set Gjoa as the default browser via MIME types")))
  (raw-body
    (imports (p "./gjoa.nix"))))
