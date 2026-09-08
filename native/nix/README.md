# Clause module comparison

`nixos-config:native/nix/btop.clause` and `nixos-config:native/nix/jq.clause`
produce Nix modules using one shared declaration source,
`nixos-config:native/nix/nixpkgs.clause`. Their generated enable options and
conditional package lists are compared with the current modules using the
repository's locked nixpkgs input.

Build `clause-workbench` from the exact revision in
`nixos-config:config/clause-revision`, read its `authoring-card`, and pass that
executable to `nixos-config:native/nix/compare.test.sh`. The check opens both
sources through reading, elaboration, lowering, and session opening, then
compiles them and evaluates default, disabled, and enabled configurations. It
compares enablement, option types, defaults, descriptions, package names, and
package output paths. Generated modules remain under
`nixos-config:.firn-build/nix-comparison/`.

The live sources remain `nixos-config:modules/btop/default.bnix` and
`nixos-config:modules/jq/default.bnix`, including their `cli-tools` tags.
The next migration seam is teaching the repository's module/tag resolver and
build driver to consume `.clause` sources before replacing those live sources.
This comparison does not activate a system configuration.

The three Clause sources follow
`clause:test-vectors/authoring/shared-foreign/` at revision
`6e25a33fbc1d7d421a36c01607734ff9d7115a2d`, under MIT, copyright 2026 Tom
Passarelli. The matching notice and license are retained in
`nixos-config:LICENSE-MIT`.
