#lang nisp

;; This file is included via imports = [ ./glide.nix ] from default.nix.
;; It does not declare options; it only provides the config block.
(raw-file
  (fn-set-rest (config lib pkgs)
    (let-in
      ([cfg 'config.myConfig.modules.glide])
      (att
        (set 'config
          (mkif 'cfg.enable
            (att
              (set 'systemd.services.glide
                (att
                  ('description "Glide touchpad motion detection daemon")
                  ('after (lst "kanata-main.service"))
                  ('wants (lst "kanata-main.service"))
                  ('wantedBy (lst "multi-user.target"))
                  ('serviceConfig
                    (att
                      ('ExecStart
                        (call 'lib.concatStringsSep " "
                          (lst
                            (s "${pkgs.glide}/bin/glide")
                            "--device" 'cfg.device
                            "--kanata-address" 'cfg.kanataAddress
                            "--virtual-key" 'cfg.virtualKey
                            "--motion-threshold" (call 'toString 'cfg.motionThreshold)
                            "--min-streak" (call 'toString 'cfg.minStreak))))
                      ('Restart "on-failure")
                      ('RestartSec 2)
                      ;; Needs access to input devices
                      ('SupplementaryGroups (lst "input")))))))))))))
