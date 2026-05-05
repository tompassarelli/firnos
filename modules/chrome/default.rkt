#lang nisp

(module-file modules chrome
  (desc "Enable Google Chrome browser")
  (option-attrs
    ('default (mkopt #:type (t-bool) #:default #f
                    #:desc "Set Chrome as the default browser via MIME types")))
  (raw-body
    (imports "./chrome.nix")))
