#lang nisp

(module-file modules discord
  (desc "Discord chat client")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'discord))))
