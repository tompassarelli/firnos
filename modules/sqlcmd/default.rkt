#lang nisp

(module-file modules sqlcmd
  (desc "sqlcmd for Microsoft SQL Server")
  (config-body
    (set environment.systemPackages (lst 'pkgs.sqlcmd))))
