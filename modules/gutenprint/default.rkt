#lang nisp

(module-file modules gutenprint
  (desc "Gutenprint printer drivers")
  (config-body
    (set services.printing.drivers (with-pkgs gutenprint))))
