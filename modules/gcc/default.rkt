#lang nisp

(module-file modules gcc
  (desc "GNU C compiler")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'gcc))))
