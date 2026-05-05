#lang nisp

(module-file modules sqlite
  (desc "SQLite database")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.sqlite))))
