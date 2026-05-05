#lang nisp

(module-file modules wf-recorder
  (desc "Wayland screen recorder")
  (config-body
    (set environment.systemPackages (lst 'pkgs.wf-recorder))))
