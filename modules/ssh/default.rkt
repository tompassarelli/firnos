#lang nisp

(module-file modules ssh
  (desc "SSH server")
  (config-body
    ;; OpenSSH daemon configuration
    (set services.openssh.enable #t)))
