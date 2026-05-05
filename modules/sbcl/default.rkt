#lang nisp

(module-file modules sbcl
  (desc "Steel Bank Common Lisp compiler")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'sbcl))))
