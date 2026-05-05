#lang nisp

(module-file modules lutris
  (desc "Lutris gaming platform")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.unstable.lutris))))
