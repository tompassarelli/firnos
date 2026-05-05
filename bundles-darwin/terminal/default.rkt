#lang nisp

;; darwin-flavored terminal bundle.
;; Differences from bundles/terminal:
;;   - kitty defaults ON (the NixOS bundle prefers ghostty)
;;   - ghostty dropped: nixpkgs package is Linux-only. On macOS install
;;     via the official .dmg from ghostty.org if you want it
(bundle-file terminal
  (desc "terminal environment")
  (sub-modules* (kitty #t) (fish #t)
                (zoxide #t) (atuin #t) (starship #t)))
