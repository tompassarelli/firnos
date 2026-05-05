#lang nisp

(module-file modules parted
  (desc "disk partitioning tool")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'parted))))
