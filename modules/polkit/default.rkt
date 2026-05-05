#lang nisp

(module-file modules polkit
  (desc "Polkit security configuration")
  (config-body
    (enable security.polkit)))
