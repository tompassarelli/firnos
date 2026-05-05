#lang nisp

(module-file modules nautilus
  (desc "Nautilus file manager")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'nautilus))))
