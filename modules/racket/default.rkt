#lang nisp

(module-file modules racket
  (desc "Racket programming language")
  (config-body
    (set environment.systemPackages (with-pkgs racket-minimal))))
