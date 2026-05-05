#lang nisp

(module-file modules pandoc
  (desc "Pandoc document converter")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'pandoc))))
