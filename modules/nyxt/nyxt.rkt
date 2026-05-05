#lang nisp

;; This file is included via imports = [ ./nyxt.nix ] from default.nix.
;; It does not declare options; it only provides the config block.
(raw-file
  (fn-set-rest (config lib pkgs)
    (let-in
      ([username 'config.myConfig.modules.users.username])
      (att
        (set 'config
          (mkif 'config.myConfig.modules.nyxt.enable
            (att
              (set 'environment.systemPackages (with-pkgs 'nyxt4))

              ;; AppImages need FUSE
              (set 'myConfig.modules.fuse.enable (mkdefault #t))
              (set 'programs.appimage.enable #t)

              (set 'xdg.mime.defaultApplications
                (mkif 'config.myConfig.modules.nyxt.default
                  (att ("\"text/html\""                "nyxt.desktop")
                       ("\"x-scheme-handler/http\""    "nyxt.desktop")
                       ("\"x-scheme-handler/https\""   "nyxt.desktop")
                       ("\"x-scheme-handler/about\""   "nyxt.desktop")
                       ("\"x-scheme-handler/unknown\"" "nyxt.desktop"))))

              (home-of username
                (set 'xdg.configFile
                  (att ("${\"nyxt/config.lisp\"}.source"
                        (call 'config.lib.file.mkOutOfStoreSymlink
                              (cat 'config.home.homeDirectory
                                   (s "/code/nixos-config/dotfiles/nyxt/config.lisp"))))))))))))))
