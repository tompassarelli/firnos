#lang nisp

(submodule-impl chrome
  (set environment.systemPackages (with-pkgs google-chrome)) (set xdg.mime.defaultApplications (mkif config.myConfig.modules.chrome.default (att ("\"text/html\"" "google-chrome.desktop") ("\"x-scheme-handler/http\"" "google-chrome.desktop") ("\"x-scheme-handler/https\"" "google-chrome.desktop") ("\"x-scheme-handler/about\"" "google-chrome.desktop") ("\"x-scheme-handler/unknown\"" "google-chrome.desktop")))))
