#lang nisp

(module-file modules nix-settings
  (desc "Nix configuration and package settings")
  (config-body
    (set nixpkgs.config.allowUnfree #t)

    (set nix.settings
      (att (experimental-features (lst "nix-command" "flakes"))
           (builders-use-substitutes #t)

           ;; Parallel build settings (maximize CPU usage)
           (max-jobs "auto")  ; Auto-detect based on CPU count
           (cores 0)          ; Cores per job (0 = use all available)

           ;; Walker binary caches (avoids building from source)
           (auto-optimise-store #t)

           (extra-substituters
             (lst "https://nix-community.cachix.org"
                  "https://walker.cachix.org"
                  "https://walker-git.cachix.org"
                  "https://devenv.cachix.org"
                  "https://quickshell.cachix.org"))
           (extra-trusted-public-keys
             (lst "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                  "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
                  "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
                  "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
                  "quickshell.cachix.org-1:vBm3s5tZThc5KDLj6zhHVCMp8wX/AZJwle9wqdi81ts="))))

    ;; Automatic garbage collection
    (set nix.gc
      (att (automatic #t)
           (dates "weekly")
           (options "--delete-older-than 30d")))

    ;; Limit number of boot generations (prevents /boot from filling up)
    (set boot.loader.systemd-boot.configurationLimit 10)))
