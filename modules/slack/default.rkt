#lang nisp

(module-file modules slack
  (desc "Slack messaging")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'slack))))
