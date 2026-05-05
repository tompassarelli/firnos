#lang nisp

(module-file modules users
  (desc "Enable user configuration")
  (option-attrs
    (username
      (mkopt #:type (t-str) #:default "tom"
             #:desc "Primary system username")))
  (config-body
    ;; Define user account
    (set users.users
      (att ("${cfg.username}"
            (att (shell 'pkgs.fish)
                 (isNormalUser #t)
                 (home (s "/home/" 'cfg.username))
                 ;; Enable 'sudo' for the user
                 (extraGroups (lst "wheel" "networkmanager" "plugdev"))))))

    ;; Sudo configuration - extend timeout to 30 minutes
    (set security.sudo.extraConfig
      (ms "Defaults timestamp_timeout=30"
          "Defaults timestamp_type=global"))

    ;; Create user directories on boot
    (set systemd.tmpfiles.rules
      (lst (s "d /home/" 'cfg.username "/Documents 0755 " 'cfg.username " users -")
           (s "d /home/" 'cfg.username "/Pictures/Screenshots 0755 " 'cfg.username " users -")
           (s "d /home/" 'cfg.username "/code 0755 " 'cfg.username " users -")
           (s "d /home/" 'cfg.username "/src 0755 " 'cfg.username " users -")))))
