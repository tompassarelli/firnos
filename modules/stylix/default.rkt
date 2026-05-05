#lang nisp

(module-file modules stylix
  (desc "Stylix base16 theming")
  (option-attrs
    (chosenTheme
      (mkopt #:type (t-str)
             #:desc "The base16 theme to use for styling (e.g., 'tokyo-night-dark', 'everforest-dark-hard')")))
  (raw-body
    (imports (p "./fonts.nix")
             (p "./xdg-portal.nix")
             (p "./stylix.nix"))))
