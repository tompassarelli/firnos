#lang nisp

(module-file modules auto-upgrade
  (desc "Automatic system updates")
  (config-body
    ;; Automatic system upgrades
    (set 'system.autoUpgrade
      (att ('enable #t)
           ('flake "/home/tom/code/nixos-config")
           ('flags (lst "--update-input" "nixpkgs"
                       "--update-input" "nixpkgs-unstable"
                       "--commit-lock-file"))
           ('dates "Sun 03:00")
           ;; Random delay up to 30min to avoid exact 3am every time
           ('randomizedDelaySec "30min")
           ;; Don't auto-reboot, just apply updates that don't need reboots
           ('allowReboot #f)))))
