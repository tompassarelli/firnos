#lang nisp

(module-file modules hugo
  (desc "Hugo static site generator")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'hugo))))
