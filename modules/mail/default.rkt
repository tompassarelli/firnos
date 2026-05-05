#lang nisp

(module-file modules mail
  (desc "email applications")
  (config-body
    (set environment.systemPackages (lst pkgs.unstable.protonmail-desktop))))
