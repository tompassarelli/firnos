function init-clj --description "Bootstrap a Clojure project with devenv + Doom Emacs tooling"
  set -l java_version 21

  # Help
  if test "$argv[1]" = "--help"; or test "$argv[1]" = "-h"
    echo "init-clj - neil new app + devenv scaffolding"
    echo ""
    echo "  init-clj <project-name>              create project with JDK 21"
    echo "  init-clj <project-name> --java 17    specify JDK version"
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
  cat > $project_name/devenv.yaml <<'YAML'
inputs:
  nixpkgs:
    url: github:cachix/devenv-nixpkgs/rolling
YAML

  # -- devenv.nix --
  cat > $project_name/devenv.nix <<NIX
{ pkgs, ... }:

{
  languages.clojure.enable = true;

  packages = [
    pkgs.jdk$java_version

    # -- doom emacs :lang clojure -- do not remove --
    # These are expected by Doom Emacs modules: :lang clojure, :checkers syntax,
    # +lsp, and :editor format. Removing them will break editor integration.
    pkgs.clj-kondo    # :checkers syntax (flycheck-clj-kondo)
    pkgs.clojure-lsp  # +lsp
    pkgs.neil          # neil.el package management from Emacs
    pkgs.jet           # jet.el data format conversion
    pkgs.cljfmt        # :editor format
    # -- end doom emacs --
  ];

  enterShell = ''
    echo "$project_name dev shell ready — \$(java -version 2>&1 | head -1)"
  '';
}
NIX

  # -- .envrc --
  echo "use devenv" > $project_name/.envrc

  # -- append devenv entries to .gitignore --
  echo "" >> $project_name/.gitignore
  echo "# devenv / direnv" >> $project_name/.gitignore
  echo ".devenv" >> $project_name/.gitignore
  echo ".direnv" >> $project_name/.gitignore
  echo ".env" >> $project_name/.gitignore

  echo ""
  echo "Next steps:"
  echo "  cd $project_name"
  echo "  direnv allow"
end
