#lang nisp

(module-file modules pavucontrol
  (desc "PulseAudio volume control")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'pavucontrol))))
