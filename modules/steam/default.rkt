#lang nisp

(module-file modules steam
  (desc "Steam gaming platform")
  (tags gui-only proprietary gpu-required network large-closure)
  (config-body
    (set programs.steam
      (att (enable #t)
           (package pkgs.unstable.steam)))))
