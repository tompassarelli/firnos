#lang nisp

(module-file modules nodejs
  (desc "Node.js runtime")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'nodejs))))
