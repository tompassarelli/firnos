#lang nisp

(module-file modules ripgrep
  (desc "ripgrep search tool")
  (config-body
    (set environment.systemPackages (with-pkgs ripgrep))))
