#lang nisp

(module-file modules hplip
  (desc "HP printer drivers")
  (config-body
    (set 'services.printing.drivers (with-pkgs 'hplip))))
