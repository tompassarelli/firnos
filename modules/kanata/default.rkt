#lang nisp

(module-file modules kanata
  (desc "Kanata keyboard remapping")
  (option-attrs
    ('devices    (mkopt #:type (t-listof (t-str))
                       #:default (lst)
                       #:desc "Input device paths for kanata to capture. Find yours with: ls /dev/input/by-id/"))
    ('configFile (mkopt #:type (t-path)
                       #:desc "Path to kanata .kbd config file"))
    ('port       (mkopt #:type (t-nullor (t-port))
                       #:default (nl)
                       #:desc "TCP port for kanata server (e.g. for glide integration)")))
  (raw-body (imports (p "./kanata.nix"))))
