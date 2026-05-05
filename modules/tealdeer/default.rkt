#lang nisp

(module-file modules tealdeer
  (desc "Enable tealdeer (tldr client)")
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    (set environment.systemPackages (with-pkgs tealdeer))
    (home-of username
      (set xdg.configFile
        (att ("${\"tealdeer/config.toml\"}.source"
              (call config.lib.file.mkOutOfStoreSymlink
                    (cat config.home.homeDirectory
                         (s "/code/nixos-config/dotfiles/tealdeer/config.toml")))))))))
