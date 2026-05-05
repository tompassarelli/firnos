#lang nisp

(module-file modules unrar
  (desc "unrar archive tool")
  (config-body
    (set environment.systemPackages (lst 'pkgs.unrar))))
