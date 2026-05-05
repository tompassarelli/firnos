#lang nisp

(module-file modules libnotify
  (desc "libnotify notification client")
  (config-body
    (set environment.systemPackages (with-pkgs libnotify))))
