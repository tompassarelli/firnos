#lang nisp

;; ashashi — macOS host (nix-darwin).
;;
;; Bootstrap and rebuild docs: docs/MACOS.md
;;
;; Pattern: enable individual modules rather than bundles. Bundles
;; reference NixOS-only modules (containers/podman, etc.) that won't
;; evaluate on darwin. Cherry-picking by module keeps eval clean.
;;
;; Most modules are mkIf-gated, so unenabled NixOS-only modules in the
;; auto-discovered tree are inert and don't break eval.

(host-file
  (set myConfig.modules.users.username "ashashi")

  (enable
    ;; Pure-pkg installs (just `environment.systemPackages`)
    myConfig.modules.gh
    myConfig.modules.delta
    myConfig.modules.ripgrep
    myConfig.modules.fd
    myConfig.modules.vim
    myConfig.modules.tree
    myConfig.modules.btop
    myConfig.modules.dust
    myConfig.modules.eza

    ;; Home-manager modules (programs.* — work on darwin via home-manager.darwinModules)
    myConfig.modules.git
    myConfig.modules.atuin
    myConfig.modules.starship

    ;; System+HM modules that target options nix-darwin also exposes
    myConfig.modules.fish
    myConfig.modules.direnv
    myConfig.modules.zoxide))
