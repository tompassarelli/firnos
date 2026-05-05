#lang nisp

(module-file modules attrsof-submodule-typo-test
  (desc "typo inside attrsOf submodule via wildcard match (users.users.<name>.X)")
  (config-body
    (set 'users.users.tom.shellz pkgs.zsh)))
