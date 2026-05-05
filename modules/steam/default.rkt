#lang nisp

(module-file modules steam
  (desc "Steam gaming platform")
  (config-body
    (set 'programs.steam
      (att ('enable #t)
           ('package 'pkgs.unstable.steam)))))
