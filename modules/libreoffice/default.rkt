#lang nisp

(module-file modules libreoffice
  (desc "Enable LibreOffice office suite")
  (config-body
    (set environment.systemPackages (with-pkgs libreoffice-fresh))))
