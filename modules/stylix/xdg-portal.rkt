#lang nisp

(raw-file
  (fn-set-rest (config lib pkgs)
    (att
      (config
        (mkif 'config.myConfig.modules.stylix.enable
          (att
            ;; Desktop Portal for app integration
            (xdg.portal.enable #t)
            (xdg.portal.extraPortals
              (lst 'pkgs.xdg-desktop-portal-gtk     ;; for GTK apps, Electron apps (Discord, Obsidian, etc.)
                   'pkgs.xdg-desktop-portal-gnome   ;; for Niri (Smithay-based, needs GNOME portal for screenshots/color picker)
                   'pkgs.kdePackages.xdg-desktop-portal-kde)) ;; for Qt apps (KDE apps, VLC, Qt Creator, etc.)
            ;; Let niri-portals.conf handle portal routing (default=gnome;gtk;)
            ;; Don't override with xdg.portal.config here
            ))))))
