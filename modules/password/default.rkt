#lang nisp

(module-file modules password
  (desc "password management tools")
  (config-body
    (set environment.systemPackages (with-pkgs bitwarden-desktop))))
