#lang nisp

(module-file modules blender
  (desc "Blender 3D editor")
  (config-body
    (set environment.systemPackages (with-pkgs blender))))
