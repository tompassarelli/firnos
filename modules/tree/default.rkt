#lang nisp

(module-file modules tree
  (desc "Enable tree file tree display utility")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'tree))))
