#lang nisp

(module-file modules ladybird
  (desc "Enable Ladybird browser (bleeding edge from git)")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.unstable.ladybird))))
