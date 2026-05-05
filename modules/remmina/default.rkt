#lang nisp

(module-file modules remmina
  (desc "Remmina remote desktop client")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    (set environment.systemPackages (with-pkgs remmina))

    ;; Disable Remmina autostart by managing a hidden desktop file
    (home-of-bare 'username
      (set xdg.configFile
        (att ("${\"autostart/remmina-applet.desktop\"}.text"
              (ms "[Desktop Entry]"
                  "Hidden=true")))))))
