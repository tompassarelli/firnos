#lang nisp

(raw-file
  (fn-set-rest (config lib pkgs)
    (att
      (set 'config
        (mkif 'config.myConfig.modules.niri.enable
          (att
            ;; Install xwayland-satellite for niri to use
            ;; Niri 25.08+ manages xwayland-satellite automatically - no systemd service needed
            (set 'environment.systemPackages (lst 'pkgs.unstable.xwayland-satellite))))))))
