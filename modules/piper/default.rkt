#lang nisp

(module-file modules piper
  (desc "gaming mouse configuration (Piper + ratbagd)")
  (config-body
    (service ratbagd)
    (set environment.systemPackages (with-pkgs piper))))
