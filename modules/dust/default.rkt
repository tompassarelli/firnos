#lang nisp

(module-file modules dust
  (desc "Enable dust disk usage analyzer")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'dust))))
