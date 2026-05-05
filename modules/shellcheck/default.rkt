#lang nisp

(module-file modules shellcheck
  (desc "ShellCheck shell script linter")
  (config-body
    (set environment.systemPackages (with-pkgs shellcheck))))
