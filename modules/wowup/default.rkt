#lang nisp

(module-file modules wowup
  (desc "WowUp-CF addon manager")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.wowup-cf))))
