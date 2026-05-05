#lang nisp

(module-file modules lem
  (desc "Lem Common Lisp editor")
  (extra-args inputs)
  (lets
    ([username config.myConfig.modules.users.username]
     ;; Patch out lem-terminal dependency — its terminal.so path gets baked into
     ;; the SBCL image but isn't a runtime dependency, so nix GCs it and SBCL
     ;; crashes on startup. Terminal emulation inside Lem isn't needed anyway.
     [lem-ncurses
      (call inputs.lem.packages.x86_64-linux.lem-ncurses.overrideLispAttrs
        (fn o
          (att
            (postPatch
              (cat (bop 'or o.postPatch (s ""))
                   (ms "sed -i 's/#-os-windows \"lem-terminal\"//' lem.asd"))))))]))
  (config-body
    (set environment.systemPackages (lst lem-ncurses))
    (home-of username
      (nix-attr-entry
        (.> "home" "file" "\".lem\"" "source")
        (call config.lib.file.mkOutOfStoreSymlink
          (s config.home.homeDirectory "/code/nixos-config/dotfiles/lem")))
      (set xdg.desktopEntries.lem
        (att (name "Lem")
             (comment "Common Lisp Editor")
             (exec (s pkgs.unstable.ghostty "/bin/ghostty -e " lem-ncurses "/bin/lem"))
             (terminal #f)
             (type "Application")
             (categories (lst "Development" "TextEditor")))))))
