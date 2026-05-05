#lang nisp

(bundle-file vpn
  (desc "VPN support")
  (sub-modules 'wireguard 'protonvpn-gui 'protonvpn-cli))
