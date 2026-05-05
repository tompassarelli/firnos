#lang nisp

(module-file modules clojure
  (desc "Clojure development (JDK, clj CLI, LSP, linting, formatting)")
  (config-body
    (set 'environment.systemPackages
      (with-do 'pkgs.unstable
        (lst 'jdk21
             'clojure
             ;; -- doom emacs :lang clojure -- do not remove --
             'clj-kondo
             'clojure-lsp
             'neil
             'jet
             'cljfmt
             ;; -- end doom emacs --
             )))))
