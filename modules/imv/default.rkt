#lang nisp

(module-file modules imv
  (desc "imv image viewer")
  (config-body
    (set environment.systemPackages (with-pkgs imv))))
