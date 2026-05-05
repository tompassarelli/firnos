#lang nisp

(module-file modules unknown-path-test
  (desc "intentional unknown option")
  (config-body
    (set 'services.pipwire.alsa.enable #t)))
