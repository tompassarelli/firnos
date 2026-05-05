#lang nisp

(module-file modules clean-test
  (desc "all valid — should produce zero errors")
  (config-body
    (set 'services.openssh.enable #t)
    (set 'networking.firewall.allowedTCPPorts (lst 80 443))
    (set 'boot.loader.systemd-boot.consoleMode "auto")))
