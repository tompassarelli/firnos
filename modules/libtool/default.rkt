#lang nisp

(module-file modules libtool
  (desc "GNU Libtool")
  (config-body
    (set environment.systemPackages (with-pkgs libtool))))
