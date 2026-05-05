#lang nisp

(raw-file
  (fn-set-rest (config lib pkgs)
    (let-in
      ([username config.myConfig.modules.users.username]
       [chosenTheme config.myConfig.modules.stylix.chosenTheme])
      (att
        (set config
          (mkif config.myConfig.modules.niri.enable
            (att
              (home-of username
                (set systemd.user.services.swaybg
                  (att
                    (Unit (att
                      (Description "Wayland wallpaper tool")
                      (PartOf (lst "graphical-session.target"))
                      (After (lst "graphical-session.target"))
                      (Requisite (lst "graphical-session.target"))))
                    (Service (att
                      (ExecStart
                        (s pkgs.bash "/bin/bash -c '"
                           pkgs.swaybg "/bin/swaybg -i \"$("
                           pkgs.fd "/bin/fd -t f . $HOME/.config/themes/"
                           chosenTheme "/wallpapers/ | "
                           pkgs.coreutils "/bin/shuf -n 1)\" --mode fill'"))
                      (Restart "on-failure")))
                    (Install (att
                      (WantedBy (lst "niri.service"))))))))))))))
