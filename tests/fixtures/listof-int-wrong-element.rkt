#lang nisp

(module-file modules listof-mismatch-test
  (desc "listOf int containing strings")
  (config-body
    (set 'networking.firewall.allowedTCPPorts (lst "80" "443"))))
