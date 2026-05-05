#lang nisp

(module-file modules guix
  (desc "GNU Guix package manager")
  (config-body
    (set 'services.guix.enable #t)))
