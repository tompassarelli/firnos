#lang nisp

(module-file modules gnome-screenshot
  (desc "GNOME Screenshot tool")
  (config-body
    (set environment.systemPackages (with-pkgs gnome-screenshot))))
