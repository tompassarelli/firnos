#lang nisp

(module-file modules imagemagick
  (desc "ImageMagick image processing")
  (config-body
    (set environment.systemPackages (with-pkgs imagemagick))))
