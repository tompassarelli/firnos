#lang nisp

(module-file modules grim
  (desc "Grim screenshot tool")
  (config-body
    (set environment.systemPackages (with-pkgs grim))))
