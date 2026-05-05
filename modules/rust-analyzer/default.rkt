#lang nisp

(module-file modules rust-analyzer
  (desc "Rust language server")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.unstable.rust-analyzer))))
