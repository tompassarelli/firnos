#lang nisp

(module-file modules styling
  (desc "system-wide theming and styling")
  (lets
    ([username config.myConfig.modules.users.username]
     [chosenTheme config.myConfig.modules.stylix.chosenTheme]

     ;; Read the base16 scheme YAML to get the variant (dark/light).
     [schemeFile (s pkgs.base16-schemes "/share/themes/" chosenTheme ".yaml")]
     [schemeYaml (call builtins.readFile schemeFile)]

     ;; Extract variant from YAML (crude but works for our use case).
     ;; Looks for lines like: variant: "dark" or variant: "light".
     [variant
      (let-in
        ([lines       (call lib.splitString "\n" schemeYaml)]
         [variantLine (call lib.findFirst
                            (fn line (call lib.hasPrefix "variant:" line))
                            ""
                            lines)]
         [match       (call builtins.match ".*variant: \"([^\"]+)\".*" variantLine)])
        ;; Fallback to "dark" if variant field is missing or malformed.
        (if-then (bop '!= match (nl))
                 (call builtins.head match)
                 "dark"))]))
  (config-body
    ;; ============ SYSTEM-LEVEL CONFIGURATION ============
    (set stylix
      (att (enable #t)
           (base16Scheme schemeFile)
           ;; Auto-detect polarity from base16 scheme variant field
           (polarity variant)
           ;; Font configuration
           (fonts (att (monospace (att (package pkgs.commit-mono)
                                       (name "CommitMono")))
                       (sansSerif (att (package pkgs.dejavu_fonts)
                                       (name "DejaVu Sans")))
                       (serif (att (package pkgs.ia-writer-quattro)
                                   (name "iA Writer Quattro S")))
                       (sizes (att (terminal 14)))))))

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of username
      ;; Stylix Firefox target configuration
      (set stylix.targets.firefox
        (att (profileNames (lst username))
             (colorTheme.enable #t)))

      ;; Themes directory (wallpapers and other theme assets)
      (set "xdg.configFile.\"themes\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/themes"))))))
