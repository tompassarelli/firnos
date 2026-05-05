#lang nisp

;; darwin-flavored development bundle.
;; Differences from bundles/development:
;;   - drops `containers` (Podman is NixOS-only; on macOS use OrbStack
;;     or Docker Desktop manually)
(bundle-file development
  (desc "core development workflow")
  (sub-modules git gh delta vim claude direnv ripgrep fd))
