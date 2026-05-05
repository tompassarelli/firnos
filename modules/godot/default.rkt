#lang nisp

(module-file modules godot
  (desc "Godot game engine")
  (config-body
    (set environment.systemPackages (lst pkgs.unstable.godot_4))))
