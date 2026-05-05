#lang nisp

(submodule-impl 'qutebrowser
  (set 'environment.systemPackages (with-pkgs 'qutebrowser)) (set 'xdg.mime.defaultApplications (mkif 'config.myConfig.modules.qutebrowser.default (att ("\"text/html\"" "org.qutebrowser.qutebrowser.desktop") ("\"x-scheme-handler/http\"" "org.qutebrowser.qutebrowser.desktop") ("\"x-scheme-handler/https\"" "org.qutebrowser.qutebrowser.desktop") ("\"x-scheme-handler/about\"" "org.qutebrowser.qutebrowser.desktop") ("\"x-scheme-handler/unknown\"" "org.qutebrowser.qutebrowser.desktop")))))
