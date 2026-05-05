#lang nisp

(module-file modules slurp
  (desc "Wayland region selector")
  (config-body
    (set environment.systemPackages (with-pkgs slurp))))
