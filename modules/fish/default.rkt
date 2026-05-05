#lang nisp

(module-file modules fish
  (desc "Fish shell configuration")
  (extra-args flakeRoot)
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    ;; ============ SYSTEM-LEVEL CONFIGURATION ============
    (set programs.fish.enable #t)

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of username
      (set programs.fish
        (att
          (enable #t)
          (shellAliases
            (att (du    "dust")
                 (ls    "eza")
                 (ps    "procs")
                 (v     "nvim")
                 (e     "emacsclient -n -c -a emacs")
                 (etui  "emacsclient -t -a emacs")
                 (gits  "git status")
                 (gitd  "git diff")
                 (gitdc "git diff --cached")
                 (gita  "git add -v . && git status")
                 (gitp  "git push")))
          (interactiveShellInit
            (ms "set -g fish_greeting"
                "fish_vi_key_bindings"
                "# Change to default directory (skip in Emacs vterm)"
                "if not set -q INSIDE_EMACS"
                "  cd ~"
                "end"))))

      ;; Symlink fish functions individually (out of store for live editing).
      ;; Whole-directory symlink would conflict with auto-generated functions
      ;; (e.g. yazi's yy.fish).
      (set xdg.configFile
        (let-in
          ([functionsDir
            (s config.home.homeDirectory "/code/nixos-config/dotfiles/fish/functions")]
           [functionFiles
            (call builtins.attrNames
              (call lib.filterAttrs
                (fn (n v) (bop &&
                               (bop == v "regular")
                               (call lib.hasSuffix ".fish" n)))
                (call builtins.readDir
                      (cat flakeRoot "/dotfiles/fish/functions"))))])
          (call lib.listToAttrs
            (call map
              (fn f (att (name (s "fish/functions/" f))
                         (value.source
                           (call config.lib.file.mkOutOfStoreSymlink
                                 (s functionsDir "/" f)))))
              functionFiles)))))))
