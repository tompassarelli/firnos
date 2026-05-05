#lang nisp

(module-file modules wine
  (desc "Wine (unstable, 32+64-bit)")
  (config-body
    (set environment.systemPackages (with-pkgs wineWowPackages.unstable winetricks))))
