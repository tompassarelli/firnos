#lang nisp

(submodule-impl 'librewolf
  (set 'environment.systemPackages (lst 'pkgs.unstable.librewolf)) (set 'xdg.mime.defaultApplications (mkif 'config.myConfig.modules.librewolf.default (att ("\"text/html\"" "librewolf.desktop") ("\"x-scheme-handler/http\"" "librewolf.desktop") ("\"x-scheme-handler/https\"" "librewolf.desktop") ("\"x-scheme-handler/about\"" "librewolf.desktop") ("\"x-scheme-handler/unknown\"" "librewolf.desktop")))))
