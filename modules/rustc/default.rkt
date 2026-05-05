#lang nisp

(module-file modules rustc
  (desc "Rust compiler")
  (config-body
    (set environment.systemPackages (lst 'pkgs.unstable.rustc))))
