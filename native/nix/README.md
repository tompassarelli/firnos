# Clause modules

`nixos-config:native/nix/btop.clause` and `nixos-config:native/nix/jq.clause`
are the original small comparison using one shared declaration source,
`nixos-config:native/nix/nixpkgs.clause`. Their generated enable options and
conditional package lists are compared with the pre-migration modules at
`d5734ff6` using the
repository's locked nixpkgs input.
The same checked module form also supplies fifteen package modules, including
ripgrep, fd, tree, wget, unzip, and curl.

Build `clause-workbench` from the exact revision in
`nixos-config:config/clause-revision`, read its `authoring-card`, and pass that
executable to `nixos-config:native/nix/compare.test.sh`. The check opens both
sources through reading, elaboration, lowering, and session opening, then
compiles them and evaluates default, disabled, and enabled configurations. It
compares enablement, option types, defaults, descriptions, package names, and
package output paths. Generated modules remain under
`nixos-config:.firn-build/nix-comparison/`.

`nixos-config:modules/<name>/tags.clause` explicitly selects
`nixos-config:native/nix/<name>.clause`, exporting `<name>-module`, as the
module source. The metadata file owns only tag membership, for example:

```clause
export tags(): Sequence<Text>
  ["cli-tools"]
```

The resolver compiles this source and calls the checked export. A result
other than `Sequence<Text>` rejects at the foreign boundary. btop and jq retain
`cli-tools`. A competing `nixos-config:modules/<name>/default.bnix` or a missing
Clause source is an error. Modules without this metadata file continue to use
their existing Beagle source. Shared declaration files are not module entries.

Set `FIRN_CLAUSE_WORKBENCH` to the executable built from
`nixos-config:config/clause-revision` before tag, inventory, and build commands.
The build driver
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
source ownership and wrongly typed tag exports.

The three Clause sources follow
`clause:test-vectors/authoring/static-modules/` at revision
`51e9e126af7029945b1e08bdb4763e6a058061e9`, under MIT, copyright 2026 Tom
Passarelli. The matching notice and license are retained in
`nixos-config:LICENSE-MIT`.
