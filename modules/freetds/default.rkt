#lang nisp

(module-file modules freetds
  (desc "FreeTDS (TDS protocol library for MSSQL)")
  (config-body
    (set environment.systemPackages (with-pkgs freetds))))
