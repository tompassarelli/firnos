#lang nisp

(module-file modules gnumake
  (desc "GNU Make build tool")
  (config-body
    (set environment.systemPackages (with-pkgs gnumake))))
