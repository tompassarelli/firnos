#lang nisp

(module-file modules youtube-music
  (desc "YouTube Music client")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.youtube-music))))
