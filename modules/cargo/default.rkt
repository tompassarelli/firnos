#lang nisp

(module-file modules cargo
  (desc "Rust package manager")
  (config-body
    (set environment.systemPackages (lst 'pkgs.unstable.cargo))))
