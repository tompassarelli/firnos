#lang nisp

(module-file modules fastfetch
  (desc "Enable fastfetch system info display")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    ;; ============ SYSTEM-LEVEL CONFIGURATION ============
    (set 'environment.systemPackages (with-pkgs 'fastfetch))

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of 'username
      ;; Fastfetch configuration
      (nix-attr-entry '("xdg" "configFile" "\"fastfetch/config.jsonc\"" "source")
        (call 'config.lib.file.mkOutOfStoreSymlink
          (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/fastfetch/config.jsonc"))))))
