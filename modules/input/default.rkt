#lang nisp

(module-file modules input
  (desc "touchpad support (libinput)")
  (config-body
    ;; Touchpad support
    (set services.libinput.enable #t)))
