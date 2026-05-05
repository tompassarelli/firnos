#lang nisp

(module-file modules vim
  (desc "Vim text editor")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'vim))))
