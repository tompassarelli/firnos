#lang nisp

(module-file modules rustfmt
  (desc "Rust formatter")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.unstable.rustfmt))))
