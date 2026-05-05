#lang nisp

(module-file modules fwupd
  (desc "fwupd firmware updater")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'fwupd))))
