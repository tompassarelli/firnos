#lang nisp

(module-file modules pomodoro
  (desc "Pomodoro timer")
  (config-body
    (set environment.systemPackages (with-pkgs pomodoro-gtk))))
