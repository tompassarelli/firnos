#lang nisp

(module-file modules mpv
  (desc "mpv media player")
  (config-body
    (set environment.systemPackages (with-pkgs mpv))))
