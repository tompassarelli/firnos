#lang nisp

(module-file modules graphviz
  (desc "Graphviz graph visualization")
  (config-body
    (set environment.systemPackages (with-pkgs graphviz))))
