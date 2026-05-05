#lang nisp

(module-file modules claude
  (desc "Claude Code CLI configuration")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.master.claude-code))

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of 'username
      ;; Claude settings.json
      (nix-attr-entry '("home" "file" "\".claude/settings.json\"" "source")
        (call 'config.lib.file.mkOutOfStoreSymlink
          (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/claude/settings.json")))

      ;; Claude custom commands directory (global commands)
      (nix-attr-entry '("home" "file" "\".claude/commands\"" "source")
        (call 'config.lib.file.mkOutOfStoreSymlink
          (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/claude/commands"))))))
