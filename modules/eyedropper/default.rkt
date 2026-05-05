#lang nisp

(module-file modules eyedropper
  (desc "Wayland color picker")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'eyedropper))))
