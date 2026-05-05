#lang nisp

(module-file modules delta
  (desc "delta git diff viewer")
  (config-body
    (set environment.systemPackages (with-pkgs delta))))
