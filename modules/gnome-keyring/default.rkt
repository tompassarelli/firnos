#lang nisp

(module-file modules gnome-keyring
  (desc "GNOME Keyring (secrets storage + Seahorse GUI)")
  (config-body
    (set 'security.pam.services.login.enableGnomeKeyring #t)
    (set 'services.gnome.gnome-keyring.enable #t)
    (set 'programs.seahorse.enable #t)))
