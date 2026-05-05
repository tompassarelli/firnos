#lang nisp

(module-file modules spotify
  (desc "Spotify TUI player")
  (config-body
    (set environment.systemPackages (with-pkgs spotify))))
