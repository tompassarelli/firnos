#lang nisp

(submodule-impl niri
  (set environment.systemPackages (lst pkgs.unstable.xwayland-satellite)))
