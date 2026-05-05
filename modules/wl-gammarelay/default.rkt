#lang nisp

(module-file modules wl-gammarelay
  (desc "Wayland gamma/temperature control")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    (set environment.systemPackages (with-pkgs wl-gammarelay-rs))

    (home-of 'username
      ;; Temperature control script
      (set xdg.configFile
        (att ("${\"wl-gammarelay/temperature-control\"}"
              (att (source
                    (call 'config.lib.file.mkOutOfStoreSymlink
                          (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/wl-gammarelay/temperature-control")))))))

      ;; wl-gammarelay systemd service
      (set systemd.user.services.wl-gammarelay
        (att (Unit
              (att (Description "Gamma control for Wayland")
                   (PartOf (lst "graphical-session.target"))
                   (After (lst "graphical-session.target"))
                   (Requisite (lst "graphical-session.target"))))
             (Service
              (att (ExecStart (s "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs"))
                   (Restart "on-failure")
                   (Type "dbus")
                   (BusName "rs.wl-gammarelay")))
             (Install
              (att (WantedBy (lst "niri.service")))))))))
