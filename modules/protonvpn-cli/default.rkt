#lang nisp

(module-file modules protonvpn-cli
  (desc "ProtonVPN CLI client")
  (config-body
    (set environment.systemPackages (with-pkgs protonvpn-cli))))
