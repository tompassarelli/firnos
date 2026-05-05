#lang nisp

(module-file modules fuse
  (desc "FUSE filesystem support")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'fuse))))
