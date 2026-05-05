#lang nisp

(module-file modules btop
  (desc "Enable btop system monitor")
  (config-body
    (set environment.systemPackages (with-pkgs btop))))
