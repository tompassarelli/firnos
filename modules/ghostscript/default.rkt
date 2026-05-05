#lang nisp

(module-file modules ghostscript
  (desc "Ghostscript PostScript interpreter")
  (config-body
    (set environment.systemPackages (with-pkgs ghostscript))))
