#lang nisp

(module-file modules wget
  (desc "wget download tool")
  (config-body
    (set environment.systemPackages (lst 'pkgs.wget))))
