#lang nisp

;; lisp redirects doom-emacs to a BUNDLE (not module), so we can't use sub-modules.
(bundle-file lisp
  (desc "Lisp development")
  (option-attrs
    ('doom-emacs.enable (mkopt #:type (t-bool) #:default #t #:desc "Enable Doom Emacs bundle"))
    ('lem.enable        (mkopt #:type (t-bool) #:default #t #:desc "Enable Lem"))
    ('sbcl.enable       (mkopt #:type (t-bool) #:default #t #:desc "Enable SBCL"))
    ('clojure.enable    (mkopt #:type (t-bool) #:default #t #:desc "Enable Clojure")))
  (config-body
    (set 'myConfig.bundles.doom-emacs.enable (mkdefault 'cfg.doom-emacs.enable))
    (set 'myConfig.modules.lem.enable        (mkdefault 'cfg.lem.enable))
    (set 'myConfig.modules.sbcl.enable       (mkdefault 'cfg.sbcl.enable))
    (set 'myConfig.modules.clojure.enable    (mkdefault 'cfg.clojure.enable))))
