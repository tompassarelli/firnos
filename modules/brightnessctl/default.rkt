#lang nisp

(module-file modules brightnessctl
  (desc "screen brightness control")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'brightnessctl))))
