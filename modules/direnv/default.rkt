#lang nisp

(module-file modules direnv
  (desc "direnv for automatic dev shell activation")
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    (set programs.direnv
      (att (enable #t)
           ;; better caching for nix flakes
           (nix-direnv.enable #t)))

    ;; Make devenv available (provides `use devenv` for direnv)
    (set environment.systemPackages (lst pkgs.unstable.devenv))

    ;; Add shell integration via home-manager
    (home-of-bare username
      (set programs.direnv
        (att (enable #t)
             (nix-direnv.enable #t)))

      ;; Register devenv's `use_devenv` function with direnv
      (nix-attr-entry '("xdg" "configFile" "\"direnv/lib/use_devenv.sh\"" "text")
                      (ms "use_devenv() {"
                          "  watch_file devenv.nix"
                          "  watch_file devenv.yaml"
                          "  watch_file devenv.lock"
                          "  watch_file .devenv.flake.nix"
                          "  eval \"$(devenv print-dev-env)\""
                          "}")))))
