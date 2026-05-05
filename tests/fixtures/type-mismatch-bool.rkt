#lang nisp

(module-file modules type-mismatch-bool-test
  (desc "bool option with string value")
  (config-body
    (set 'services.openssh.enable "yes")))
