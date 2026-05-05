#lang nisp

(module-file modules obs-studio
  (desc "OBS Studio screen recording")
  (config-body
    (set environment.systemPackages (with-pkgs obs-studio))))
