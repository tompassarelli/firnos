#lang nisp

;; Included via imports = [ ./palefox.nix ] from default.rkt.
;; The firefox.palefox.enable option is declared in firefox/default.rkt.
(raw-file
  (fn-set-rest (config lib pkgs inputs)
    (let-in
      ([username 'config.myConfig.modules.users.username]

       ;; palefox flake input — `inputs.palefox` resolves to the flake's source
       ;; tree (path-based, re-read every evaluation).
       [palefoxRoot 'inputs.palefox]

       ;; Wrap Firefox: bake palefox's hash-pinned bootstrap directly into the
       ;; Nix-store derivation.
       [palefoxFirefox
        (call 'pkgs.firefox.overrideAttrs
          (fn old
            (att
              ('buildCommand
                (cat
                  (bop 'or 'old.buildCommand "")
                  (ms "cat >> \"$out/lib/firefox/defaults/pref/autoconfig.js\" <<'EOF'"
                      "pref(\"general.config.filename\", \"config.js\");"
                      "pref(\"general.config.sandbox_enabled\", false);"
                      "EOF"
                      (s "cp " palefoxRoot "/program/config.generated.js \"$out/lib/firefox/config.js\"")))))))])
      (att
        (set 'config
          (mkif 'config.myConfig.modules.firefox.palefox.enable
            (att
              ;; Palefox implies firefox
              (set 'myConfig.modules.firefox.enable (mkdefault #t))

              ;; palefox: system-level Firefox with hash-pinned JS loader baked in
              (set 'programs.firefox
                (att ('enable #t)
                     ('package palefoxFirefox)))

              (home-of username
                (set 'programs.firefox
                  (att
                    ('enable #t)
                    ('package palefoxFirefox)
                    (set "profiles.${username}"
                      (att
                        ('settings
                          (att
                            ("\"toolkit.legacyUserProfileCustomizations.stylesheets\"" #f)
                            ("\"userChromeJS.enabled\"" #t)
                            ("\"browser.toolbars.bookmarks.visibility\"" "never")
                            ("\"devtools.chrome.enabled\"" #t)
                            ("\"devtools.debugger.remote-enabled\"" #t)))
                        ('extensions
                          (att
                            ('force #t)
                            ('packages
                              (lst
                                (nix-ident "inputs.nur.legacyPackages.${pkgs.system}.repos.rycee.firefox-addons.sidebery")))))))))

                ;; Symlink palefox chrome dir into the profile (out-of-store).
                (set "home.file.\".mozilla/firefox/${username}/chrome\".source"
                  (call 'config.lib.file.mkOutOfStoreSymlink
                        (s "/home/" username "/code/palefox/chrome")))))))))))
