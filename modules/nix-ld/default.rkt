#lang nisp

(module-file modules nix-ld
  (desc "nix-ld dynamic library shim")
  (config-body
    (set programs.nix-ld.enable #t)))
