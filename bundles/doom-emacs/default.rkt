#lang nisp

(bundle-file doom-emacs
  (desc "Doom Emacs (emacs + build deps + tools)")
  (sub-modules
    'doom-emacs 'emacs 'nerd-fonts 'ripgrep 'fd
    'clang 'cmake 'gnumake 'gcc 'libtool 'sbcl
    'gnome-screenshot 'graphviz 'shellcheck))
