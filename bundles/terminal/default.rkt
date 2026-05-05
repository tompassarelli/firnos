#lang nisp

(bundle-file terminal
  (desc "terminal environment")
  (sub-modules* ('kitty #f) ('ghostty #t) ('fish #t)
                ('zoxide #t) ('atuin #t) ('starship #t)))
