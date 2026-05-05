#lang nisp

(raw-file
  (fn-set-rest (config lib pkgs)
    (let-in
      ([username 'config.myConfig.modules.users.username])
      (att
        (set config
          (mkif 'config.myConfig.modules.niri.enable
            (att
              (home-of username
                (set systemd.user.services.swayidle
                  (att
                    (Unit (att
                      (Description "Idle manager for Wayland")
                      (PartOf (lst "graphical-session.target"))
                      (After (lst "graphical-session.target"))
                      (Requisite (lst "graphical-session.target"))))
                    (Service (att
                      (ExecStart (s 'pkgs.swayidle "/bin/swayidle -w timeout 601 'niri msg action power-off-monitors' timeout 600 'swaylock -f' before-sleep 'swaylock -f'"))
                      (Restart "on-failure")))
                    (Install (att
                      (WantedBy (lst "niri.service"))))))))))))))
