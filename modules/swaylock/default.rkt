#lang nisp

(module-file modules swaylock
  (desc "swaylock screen locker")
  (config-body
    (set environment.systemPackages (lst pkgs.swaylock))))
