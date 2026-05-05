#lang nisp

(module-file modules upower
  (desc "UPower power management")
  (config-body
    ;; Power monitoring
    (set 'services.upower.enable #t)))
