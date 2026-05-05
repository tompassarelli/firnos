#lang nisp

(module-file modules appimage
  (desc "AppImage support via appimage-run + binfmt")
  (config-body
    (set programs.appimage
      (att (enable #t)
           (binfmt #t)))))
