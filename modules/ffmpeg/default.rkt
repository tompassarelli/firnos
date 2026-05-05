#lang nisp

(module-file modules ffmpeg
  (desc "FFmpeg video processing")
  (config-body
    (set environment.systemPackages (with-pkgs ffmpeg))))
