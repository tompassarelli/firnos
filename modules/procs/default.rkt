#lang nisp

(module-file modules procs
  (desc "Enable procs (modern ps replacement)")
  (config-body
    (set environment.systemPackages (with-pkgs procs))))
