#lang nisp

(bundle-file desktop
  (desc "Wayland desktop environment")
  (sub-modules
    'niri 'upower 'rofi 'quickshell 'wl-clipboard 'brightnessctl
    'libnotify 'wl-gammarelay 'mako 'nautilus 'swaylock 'grim 'slurp
    'pavucontrol 'ffmpeg 'wf-recorder 'eyedropper))
