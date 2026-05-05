#lang nisp

(module-file modules zoom
  (desc "Zoom video conferencing")
  (config-body
    (set environment.systemPackages (lst pkgs.zoom-us))))
