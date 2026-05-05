#lang nisp

(module-file modules unzip
  (desc "unzip archive tool")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.unzip))))
