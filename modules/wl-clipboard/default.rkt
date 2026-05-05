#lang nisp

(module-file modules wl-clipboard
  (desc "Wayland clipboard utilities")
  (config-body
    (set environment.systemPackages (with-pkgs wl-clipboard))))
