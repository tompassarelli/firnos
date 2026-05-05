#lang nisp

(module-file modules zathura
  (desc "Zathura PDF viewer")
  (config-body
    (set environment.systemPackages (lst 'pkgs.zathura))))
