#lang nisp

(module-file modules pkg-config
  (desc "pkg-config build tool")
  (config-body
    (set environment.systemPackages (with-pkgs pkg-config))))
