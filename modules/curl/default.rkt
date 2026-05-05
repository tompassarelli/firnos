#lang nisp

(module-file modules curl
  (desc "curl HTTP client")
  (config-body
    (set environment.systemPackages (with-pkgs curl))))
