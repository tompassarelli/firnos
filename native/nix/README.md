# Clause modules

`nixos-config:native/nix/btop.clause` and `nixos-config:native/nix/jq.clause`
own the btop and jq Nix modules using one shared declaration source,
`nixos-config:native/nix/nixpkgs.clause`. Their generated enable options and
conditional package lists are compared with the pre-migration modules at
`d5734ff6` using the
repository's locked nixpkgs input.

Build `clause-workbench` from the exact revision in
`nixos-config:config/clause-revision`, read its `authoring-card`, and pass that
executable to `nixos-config:native/nix/compare.test.sh`. The check opens both
sources through reading, elaboration, lowering, and session opening, then
compiles them and evaluates default, disabled, and enabled configurations. It
compares enablement, option types, defaults, descriptions, package names, and
package output paths. Generated modules remain under
`nixos-config:.firn-build/nix-comparison/`.

`nixos-config:modules/<name>/tags.bnix` explicitly selects
`nixos-config:native/nix/<name>.clause`, exporting `<name>-module`, as the
module source. The metadata file owns only tag membership; btop and jq retain
`cli-tools`. A competing `nixos-config:modules/<name>/default.bnix` or a missing
Clause source is an error. Modules without this metadata file continue to use
their existing Beagle source. Shared declaration files are not module entries.

Set `FIRN_CLAUSE_WORKBENCH` to the executable built from
`nixos-config:config/clause-revision` before `firn repo build`. The build driver
discovers the selected source, compiles it to the existing
`nixos-config:modules/<name>/default.nix`, and retains the flake's ordinary
directory discovery. `firn repo diff native/nix` checks the generated outputs.
Both source forms use the same tag resolver. These commands do not activate a
system configuration.

With `BEAGLE_PATH` set to the repository's Beagle compiler, run
`nixos-config:native/nix/resolver.test.sh` with the pinned workbench executable
as its argument. It builds the resolver/build graph, discovers and compiles the
two actual sources in a fixture, checks their tags and generated outputs,
evaluates them against the original modules, and rejects conflicting or missing
source ownership.

The three Clause sources follow
`clause:test-vectors/authoring/shared-foreign/` at revision
`6e25a33fbc1d7d421a36c01607734ff9d7115a2d`, under MIT, copyright 2026 Tom
Passarelli. The matching notice and license are retained in
`nixos-config:LICENSE-MIT`.
