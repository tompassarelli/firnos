#lang nisp

(module-file modules nerd-fonts
  (desc "Nerd Fonts symbols")
  (config-body
    (set fonts.packages (lst 'pkgs.nerd-fonts.symbols-only))))
