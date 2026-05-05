#lang nisp

(module-file modules gh
  (desc "GitHub CLI")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'gh))))
