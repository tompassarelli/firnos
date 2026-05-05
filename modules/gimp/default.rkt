#lang nisp

(module-file modules gimp
  (desc "GIMP image editor")
  (config-body
    (set environment.systemPackages (with-pkgs gimp))))
