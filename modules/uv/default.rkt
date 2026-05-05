#lang nisp

(module-file modules uv
  (desc "uv Python package manager")
  (config-body
    (set environment.systemPackages (lst pkgs.uv))))
