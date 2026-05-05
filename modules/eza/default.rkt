#lang nisp

(module-file modules eza
  (desc "Enable eza (modern ls replacement)")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'eza))))
