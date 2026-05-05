#lang nisp

(module-file modules clang
  (desc "Clang C/C++ compiler")
  (config-body
    (set environment.systemPackages (with-pkgs clang))))
