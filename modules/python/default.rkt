#lang nisp

(module-file modules python
  (desc "Python runtime with uv")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'python3))))
