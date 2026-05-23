<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/firnos-logo.png" width="150">
    <source media="(prefers-color-scheme: light)" srcset="assets/firnos-logo-dark.png" width="150">
    <img alt="FirnOS" src="assets/firnos-logo.png" width="150">
  </picture>
</p>

**FirnOS is a source-aware authoring layer for NixOS and nix-darwin.**

Keeps the standard NixOS module model, swaps in a small Racket DSL
([beagle/nix](https://github.com/tompassarelli/beagle)) for authoring,
adds pre-eval diagnostics that catch option typos and type errors at
the source line — typically cutting edit/validate loops from
~30 seconds to ~5 seconds.

```
$ firn host rebuild
modules/printing/default.bnix:6:7: unknown option services.pipwire.alsa.enable
  did you mean: services.pipewire.alsa.enable or services.pipewire.pulse.enable?
modules/foo/default.bnix:9:34: type mismatch at services.openssh.enable:
  expected bool, got string
hosts/laptop/configuration.bnix:11:47: type mismatch at boot.loader.systemd-boot.consoleMode:
  "atuo" not in enum {…} — did you mean "auto"?
```

`file:line:col` precision on the value, with did-you-mean suggestions,
before `nixos-rebuild` runs. That's the whole pitch. See
[docs/VALIDATION.md](docs/VALIDATION.md) for the validator pipeline.

## Who is this for?

This repository is two things at once: the FirnOS framework, and the
author's real NixOS + nix-darwin config built on it. To use FirnOS for
your own machines, **start from [`template/`](template/)**. The full
repo (`hosts/whiterabbit/`, ~158 modules, every bundle) is here as a
study reference, not as something to fork wholesale.

## Quick start

```bash
nix flake init -t github:tompassarelli/firnos     # drops template/ in cwd
git clone https://github.com/tompassarelli/beagle ../beagle    # compiler + validator
cp /etc/nixos/hardware-configuration.nix .
# edit hosts/my-machine/configuration.bnix — set username, enable bundles
./scripts/firn-build && nixos-rebuild switch --flake .#my-machine
```

`BEAGLE_PATH` overrides the sibling-clone location. On macOS, see
[docs/MACOS.md](docs/MACOS.md).

## Daily commands

```bash
firn rebuild          # build + validate + switch (current host)
firn validate         # static check the .bnix tree
firn impact           # preview what would build
firn diff             # diff regenerated .nix vs committed
firn enable <name>    # toggle a module or bundle on
```

These are first-class bare shortcuts — defaults are auto-detected
(current host, `all` for aggregates). Full reference (and the
underlying `<node> <edge> [<leaf>]` graph for scoping to other hosts):
[docs/CLI.md](docs/CLI.md).

## Architecture

- **Module** = atom. One package or service.
- **Bundle** = molecule. Pure composition. Enables modules; never
  installs packages.
- **Host** = leaf. Enables modules + bundles.

`firn rebuild` runs `firn-build` → `firn-validate` → `nixos-rebuild` →
tag. Modules and bundles auto-discover via the flake's dynamic
`imports`.

```
.
├── flake.rkt          source-of-truth flake (#lang nisp — see note below)
├── flake.nix          generated
├── modules/  bundles/  bundles-darwin/  hosts/    .bnix source
├── scripts/           firn (CLI), firn-build, firn-validate, firn-extract-schema
├── template/          starting point for `nix flake init -t`
├── dotfiles/  secrets/  assets/
├── docs/              AUTHORING / CLI / VALIDATION / USING-AS-INPUT / MACOS / BUILDING
└── tests/             validator regression fixtures (.bnix)
```

> **`flake.rkt` note.** `flake.rkt` is the one remaining `#lang nisp`
> source — `beagle-import-nix` deliberately refuses `flake-file` forms.
> Everything else (modules, bundles, hosts, test fixtures) is `.bnix`.

## Documentation

- [docs/AUTHORING.md](docs/AUTHORING.md) — module / bundle / host
  examples, escape hatch, migrating existing Nix
- [docs/CLI.md](docs/CLI.md) — full `firn` command reference
- [docs/VALIDATION.md](docs/VALIDATION.md) — validator pipeline, schema
  cache, freshness rules
- [docs/USING-AS-INPUT.md](docs/USING-AS-INPUT.md) — consuming FirnOS
  as a flake input, `lib.mkSystem` / `lib.mkDarwinSystem` reference
- [docs/MACOS.md](docs/MACOS.md) — nix-darwin bootstrap walkthrough
- [docs/BUILDING.md](docs/BUILDING.md) — DSL forms, pipeline internals
- [tompassarelli/beagle](https://github.com/tompassarelli/beagle) —
  the DSL itself, compiler, validator, schema extractor, migration tool

## Tradeoffs

- One sibling-repo dependency (`../beagle`).
- Two-language requirement (Racket s-expressions + Nix concepts).
- Two artifacts per file (`.bnix` + `.nix`, both committed).
- Schema cache is host-specific and dated; regenerate after flake
  input changes.
- DSL ceiling — escape hatch (`raw-file`, hand-written `.nix`,
  `nix-ident`) covers the gaps.

## Inspired by

[doomemacs/doomemacs](https://github.com/doomemacs/doomemacs) ·
[basecamp/omarchy](https://github.com/basecamp/omarchy) ·
[fufexan/dotfiles](https://github.com/fufexan/dotfiles) ·
[redyf/nixdots](https://github.com/redyf/nixdots) ·
[eduardofuncao/nixferatu](https://github.com/eduardofuncao/nixferatu)

## License

MIT
