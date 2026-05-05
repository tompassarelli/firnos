#lang nisp

(module-file modules cmake
  (desc "CMake build system")
  (config-body
    (set environment.systemPackages (with-pkgs cmake))))
