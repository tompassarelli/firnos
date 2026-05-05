#lang nisp

(bundle-file printing
  (desc "printing support (CUPS + drivers)")
  (sub-modules 'printing 'gutenprint 'hplip))
