#lang nisp

(module-file modules dbeaver
  (desc "DBeaver database GUI")
  (config-body
    (set environment.systemPackages (with-pkgs dbeaver-bin))))
