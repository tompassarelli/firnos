#lang nisp

(module-file modules rustdesk
  (desc "RustDesk remote desktop")
  (config-body
    (set environment.systemPackages (with-pkgs rustdesk-flutter))))
