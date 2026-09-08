#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
workbench="${1:?pass the clause-workbench executable built from config/clause-revision}"
discovered="${2:-$repo}"
output="$repo/.firn-build/nix-comparison"
mkdir -p "$output/baseline"

for name in btop jq; do
  git -C "$repo" show "d5734ff6:modules/$name/default.nix" >"$output/baseline/$name.nix"
  "$workbench" check-source "$here/$name.clause"
  "$workbench" compile-nix "$here/$name.clause" "$name-module" "$output/$name.nix"
done

# Nix's module evaluator is the foreign-system boundary being compared.
FIRN_NIX_COMPARISON_REPO="$repo" FIRN_NIX_COMPARISON_OUTPUT="$output" \
FIRN_NIX_COMPARISON_DISCOVERED="$discovered" \
  nix eval --impure --json --expr '
    let
      repo = builtins.getEnv "FIRN_NIX_COMPARISON_REPO";
      output = builtins.getEnv "FIRN_NIX_COMPARISON_OUTPUT";
      discovered = builtins.getEnv "FIRN_NIX_COMPARISON_DISCOVERED";
      flake = builtins.getFlake ("git+file://" + repo);
      pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
      lib = pkgs.lib;
      inspect = name: module: enabled:
        let
          evaluated = lib.evalModules {
            specialArgs = { inherit pkgs; };
            modules = [
              { options.environment.systemPackages = lib.mkOption {
                  type = lib.types.listOf lib.types.package;
                  default = [];
                };
              }
              module
            ] ++ lib.optional (enabled != null) {
              myConfig.modules.${name}.enable = enabled;
            };
          };
          option = evaluated.options.myConfig.modules.${name}.enable;
        in {
          enabled = evaluated.config.myConfig.modules.${name}.enable;
          packages = map (package: {
            inherit (package) name outPath;
          }) evaluated.config.environment.systemPackages;
          type = option.type.name;
          default = option.default;
          description = option.description;
        };
      compare = name: map (enabled:
        let
          actual = inspect name (import (output + "/" + name + ".nix")) enabled;
          selected = inspect name (import (discovered + "/modules/" + name + "/default.nix")) enabled;
          expected = inspect name (import (output + "/baseline/" + name + ".nix")) enabled;
        in assert actual == expected; assert selected == expected; actual
      ) [ null false true ];
    in { btop = compare "btop"; jq = compare "jq"; }
  '
