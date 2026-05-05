#lang nisp

(module-file modules protonvpn-gui
  (desc "ProtonVPN GUI client")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'protonvpn-gui))))
