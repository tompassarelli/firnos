#lang nisp

;; darwin-flavored cli-tools bundle.
;; Identical to bundles/cli-tools — every module here is pure-pkg or
;; home-manager-only, all darwin-safe.
(bundle-file cli-tools
  (desc "modern CLI tools")
  (sub-modules
    yazi tree dust eza procs tealdeer fastfetch btop
    unrar curl wget unzip imagemagick ghostscript))
