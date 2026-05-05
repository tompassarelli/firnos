#lang nisp

;; ashashi — macOS host (nix-darwin).
;;
;; Bootstrap and rebuild docs: docs/MACOS.md
;;
;; Bundles live in `bundles-darwin/` (auto-discovered by lib.mkDarwinSystem).
;; They share the `myConfig.bundles.<name>` namespace with their NixOS
;; siblings, so the same `(enable myConfig.bundles.terminal)` works on
;; either platform and gets the right per-platform composition.

(host-file
  (set myConfig.modules.users.username "ashashi")

  (enable
    myConfig.bundles.terminal       ; kitty + ghostty + fish + zoxide + atuin + starship
    myConfig.bundles.cli-tools      ; yazi, tree, dust, eza, procs, tealdeer, btop, …
    myConfig.bundles.development))  ; git, gh, delta, vim, claude, direnv, ripgrep, fd
