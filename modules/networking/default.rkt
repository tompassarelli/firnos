#lang nisp

(module-file modules networking
  (desc "network configuration")
  (config-body
    (set 'networking.networkmanager.enable #t)
    (set 'networking.networkmanager.unmanaged (lst "interface-name:wg*"))
    (set 'networking.networkmanager.wifi.powersave #f)
    (set 'networking.networkmanager.logLevel "DEBUG")
    (set 'environment.systemPackages (with-pkgs 'networkmanagerapplet))))
