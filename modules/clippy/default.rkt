#lang nisp

(module-file modules clippy
  (desc "Rust linter")
  (config-body
    (set environment.systemPackages (lst pkgs.unstable.clippy))))
