#lang nisp

(raw-file
  (fn-set-rest (config lib pkgs)
    (let-in
      ([cfg config.myConfig.modules.kanata])
      (att
        (set config
          (mkif cfg.enable
            (att
              (set hardware.uinput.enable #t)
              (set services.udev.extraRules
                (ms "KERNEL==\"uinput\", MODE=\"0660\", GROUP=\"uinput\", OPTIONS+=\"static_node=uinput\""))
              (set users.groups.uinput (att))
              (set users.users.kanata
                (att (isSystemUser #t)
                     (group "kanata")
                     (extraGroups (lst "input" "uinput"))))
              (set users.groups.kanata (att))
              (set services.kanata
                (att (enable #t)
                     (package pkgs.kanata-git)
                     (keyboards
                       (mkif (bop != cfg.devices (lst))
                         (att
                           (main
                             (att
                               (devices cfg.devices)
                               (port (mkif (bop != cfg.port (nl)) cfg.port))
                               (extraDefCfg "process-unmapped-keys yes")
                               (config (call builtins.readFile cfg.configFile)))))))))
              (set systemd.services.kanata-main.serviceConfig
                (mkif (bop != cfg.devices (lst))
                  (att
                    (DynamicUser (mkforce #f))
                    (User "kanata")))))))))))
