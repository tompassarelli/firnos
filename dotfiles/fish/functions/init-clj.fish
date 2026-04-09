function init-clj --description "Bootstrap a Clojure project with devenv + Doom Emacs tooling"
  set -l java_version 25

  # Help
  if test "$argv[1]" = "--help"; or test "$argv[1]" = "-h"
    echo "init-clj - neil new app + devenv scaffolding"
    echo ""
    echo "  init-clj <project-name>              create project with JDK 25"
    echo "  init-clj <project-name> --java 21    specify JDK version"
    return
  end

  # Parse args
  set -l project_name
  set -l i 1
  while test $i -le (count $argv)
    switch $argv[$i]
      case --java
        set i (math $i + 1)
        set java_version $argv[$i]
      case '-*'
        echo "Unknown flag: $argv[$i]"
        return 1
      case '*'
        set project_name $argv[$i]
    end
    set i (math $i + 1)
  end

  if test -z "$project_name"
    echo "Usage: init-clj <project-name> [--java VERSION]"
    return 1
  end

  if test -d "$project_name"
    echo "error: $project_name already exists"
    return 1
  end

  # -- neil scaffolds the Clojure project --
  neil new app $project_name
  or return 1

  # -- devenv.yaml --
  printf '%s\n' \
    'inputs:' \
    '  nixpkgs:' \
    '    url: github:cachix/devenv-nixpkgs/rolling' \
    > $project_name/devenv.yaml

  # -- devenv.nix --
  printf '%s\n' \
    '{ pkgs, ... }:' \
    '' \
    '{' \
    '  packages = [' \
    "    pkgs.jdk$java_version" \
    '    pkgs.clojure' \
    '' \
    '    # -- doom emacs :lang clojure -- do not remove --' \
    '    # These are expected by Doom Emacs modules: :lang clojure, :checkers syntax,' \
    '    # +lsp, and :editor format. Removing them will break editor integration.' \
    '    pkgs.clj-kondo    # :checkers syntax (flycheck-clj-kondo)' \
    '    pkgs.clojure-lsp  # +lsp' \
    '    pkgs.neil          # neil.el package management from Emacs' \
    '    pkgs.jet           # jet.el data format conversion' \
    '    pkgs.cljfmt        # :editor format' \
    '    # -- end doom emacs --' \
    '  ];' \
    '' \
    '  enterShell = '"'"''"'"'"' \
    "    echo \"$project_name dev shell ready — \$(java -version 2>&1 | head -1)\"" \
    '  '"'"''"'"';' \
    '}' \
    > $project_name/devenv.nix

  # -- dev/user.clj (REPL startup) --
  mkdir -p $project_name/dev
  printf '%s\n' \
    "(ns user)" \
    > $project_name/dev/user.clj

  # -- add :dev alias to deps.edn --
  sed -i 's/{:run-m/{:dev {:extra-paths ["dev"]}\n  :run-m/' $project_name/deps.edn

  # -- .envrc --
  echo "use devenv" > $project_name/.envrc

  # -- append devenv entries to .gitignore --
  echo "" >> $project_name/.gitignore
  echo "# devenv / direnv" >> $project_name/.gitignore
  echo ".devenv" >> $project_name/.gitignore
  echo ".direnv" >> $project_name/.gitignore
  echo ".env" >> $project_name/.gitignore

  # -- pre-allow direnv so cd doesn't nag --
  direnv allow $project_name

  echo ""
  echo "Done! cd $project_name"
end
