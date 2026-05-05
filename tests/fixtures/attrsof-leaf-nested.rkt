#lang nisp

(module-file modules attrsof-leaf-nested-test
  (desc "attrsOf str with nested attrset value (leaf scalar expected)")
  (config-body
    (set 'hardware.alsa.deviceAliases (att (foo (att (nested "x")))))))
