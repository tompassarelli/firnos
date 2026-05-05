#lang nisp

(module-file modules fd
  (desc "fd file finder")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'fd))))
