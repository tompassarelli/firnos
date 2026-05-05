#lang nisp

(module-file modules emacs
  (desc "GNU Emacs editor")
  (config-body
    (set environment.systemPackages (with-pkgs emacs-pgtk))))
