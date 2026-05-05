#lang nisp

(bundle-file auth
  (desc "authentication (polkit + GNOME Keyring)")
  (sub-modules 'polkit 'gnome-keyring))
