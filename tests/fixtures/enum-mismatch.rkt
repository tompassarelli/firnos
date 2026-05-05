#lang nisp

(module-file modules enum-mismatch-test
  (desc "enum value not in allowed set, with near-miss for did-you-mean")
  (config-body
    (set 'boot.loader.systemd-boot.consoleMode "atuo")))
