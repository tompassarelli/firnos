<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/firnos-logo.png" width="150">
    <source media="(prefers-color-scheme: light)" srcset="assets/firnos-logo-dark.png" width="150">
    <img alt="FirnOS" src="assets/firnos-logo.png" width="150">
  </picture>
</p>

**FirnOS is a source-aware authoring layer for NixOS and nix-darwin.**

It keeps the standard NixOS module model, swaps in a small Racket DSL
([beagle/nix](https://github.com/tompassarelli/beagle)) for the authoring
surface, and adds pre-eval diagnostics that catch option typos and type
errors at the source line — typically cutting edit/validate loops from
~30 seconds to ~5 seconds.

Both `.bnix` (source) and `.nix` (generated) are committed. The flake
reads ordinary Nix. You're not trapped in a custom language — drop down
to raw Nix anywhere, or walk away from FirnOS by deleting the `.bnix`
files and keeping the `.nix`.

## Who is this for?

This repository is two things at once: the FirnOS framework, and the
author's real NixOS + nix-darwin config built on it. If you want to use
FirnOS for your own machines, **start from [`template/`](template/)**.
The full repo (`hosts/whiterabbit/`, all ~158 modules, every bundle, the
secrets and dotfiles wiring) is here as a study reference for what a
daily-driver setup looks like, not as something to fork wholesale.

Three audiences:

- **You want to manage your own NixOS or nix-darwin machine** with
  source-aware validation and a small workflow CLI → use the
  [template](#quick-start).
- **You want the validation tooling but already have a Nix config** →
  look at [tompassarelli/nisp](https://github.com/tompassarelli/nisp).
  Its `validate` / `schema` / `rename` / `import` subcommands plus
  `nisp-lsp` work standalone against any flake.
- **You want to read a real example of a multi-host Nix config** →
  browse `hosts/`, `modules/`, `bundles/`. Everything in this repo
  evaluates and builds.

## What the checker catches

```
$ firn host rebuild
modules/printing/default.bnix:6:7: unknown option services.pipwire.alsa.enable
  did you mean: services.pipewire.alsa.enable or services.pipewire.pulse.enable?
modules/net/default.bnix:10:47: unknown package networkmanagers in pkgs set
  did you mean: networkmanager, networkmanager-ssh or networkmanager-sstp?
modules/foo/default.bnix:9:34: type mismatch at services.openssh.enable:
  expected bool, got string
hosts/laptop/configuration.bnix:11:47: type mismatch at boot.loader.systemd-boot.consoleMode:
  "atuo" not in enum {"0", "1", "2", "5", "auto", "max", "keep"} — did you mean "auto"?
modules/bar/default.bnix:8:9: duplicate assignment to networking.hostName (first set at line 5)
```

`file:line:col` precision **on the value, not the option path**, with
did-you-mean suggestions, before `nixos-rebuild` runs. That's the whole
pitch.

## What it is

Three pieces on top of the standard NixOS module system:

- **beagle/nix** — a Racket `#lang` for writing Nix as s-expressions.
  Sources live in `.bnix` files; `beagle-build` compiles each one to a
  sibling `.nix`. Lives in [tompassarelli/beagle](https://github.com/tompassarelli/beagle).
- **The nisp validation toolchain** — `beagle-validate` (or `nisp
  validate` as a fallback) walks every `.bnix`, resolves each
  `(set 'PATH val)` and `(enable 'PATH)` against the cached NixOS
  options schema (~16k paths) and the home-manager schema (~3.7k paths),
  type-checks values, validates every `pkgs.<name>` against the cached
  nixpkgs attr index, and reports mismatches at `file:line:col`. Used
  standalone, the dispatcher in
  [tompassarelli/nisp](https://github.com/tompassarelli/nisp) works
  against any flake.
- **`firn`** — the CLI that wraps daily workflow: rebuild, validate,
  enable/disable modules and bundles, schema introspection, scaffolding,
  secrets, health checks, watch-on-save.

Plus the framework conventions: `myConfig.modules.*` for atomic
packages/services, `myConfig.bundles.*` for composable groups,
directory auto-discovery — adding a module is just creating a
directory.

## Why this works

NixOS already validates option paths and types — but it does so during
module evaluation, after the original authoring context is gone. By the
time an error surfaces, the line that caused it is several layers of
`mkIf`/`mkMerge`/import indirection away. The error message points at
where the option got *forced*, not where the typo was *written*.

FirnOS validates at a different layer. The `.bnix` AST is a concrete
data structure in memory before any Nix is emitted. The validator walks
it, extracts every `(set 'PATH val)` / `(enable 'PATH)`, looks the path
up in the cached schema (exported once via `nix eval` against the
options tree), and reports mismatches with `file:line:col` from the
original source.

Typo and type errors surface at the line you wrote, in milliseconds,
before any `nixos-rebuild` evaluation cost.

## Quick start

For your own setup, scaffold from the template:

```bash
nix flake init -t github:tompassarelli/firnos     # drops template/ contents in cwd
git clone https://github.com/tompassarelli/beagle ../beagle    # compiler + validator
git clone https://github.com/tompassarelli/nisp ../nisp        # schema/package extraction
cp /etc/nixos/hardware-configuration.nix .
# edit hosts/my-machine/configuration.bnix — set username, enable bundles
./scripts/firn-build && nixos-rebuild switch --flake .#my-machine
```

`BEAGLE_PATH` and `NISP_PATH` override the sibling-clone locations if
you want to keep them elsewhere.

To study the full author config instead:

```bash
git clone https://github.com/tompassarelli/firnos
git clone https://github.com/tompassarelli/beagle
git clone https://github.com/tompassarelli/nisp
# poke around hosts/, modules/, bundles/. Don't rebuild it as-is —
# it's tuned to a specific Framework 13 laptop.
```

On macOS, see [`docs/MACOS.md`](docs/MACOS.md) — FirnOS supports
nix-darwin via `lib.mkDarwinSystem` with curated `bundles-darwin/`.

## Migrating from existing Nix

If you already have a hand-written Nix config, the `nisp import`
subcommand converts `.nix` → `.bnix`:

```bash
nisp import path/to/configuration.nix > hosts/my-machine/configuration.bnix
```

Round-trip is byte-equivalent for plain Nix; the importer covers 100%
of nixpkgs (~2,300 modules) via rnix-parser. Comments are dropped
(logged limitation). After importing, hand-written `.nix` and generated
`.nix` can sit side by side — `firn-build` only rewrites files that
have a `.bnix` source.

## Authoring config

A trivial install-package module:

```racket
;; modules/vim/default.bnix
#lang beagle/nix
(ns modules.vim)

(module [config lib pkgs]
  {:options.myConfig.modules.vim.enable
     (lib/mkEnableOption "Vim text editor")

   :config
     (lib/mkIf config.myConfig.modules.vim.enable
       {:environment.systemPackages (with-do pkgs [vim])})})
```

A bundle that toggles a group of modules, with per-child opt-out:

```racket
;; bundles/terminal/default.bnix
#lang beagle/nix
(ns bundles.terminal)

(module [config lib pkgs]
  {:options.myConfig.bundles.terminal
     {:enable (lib/mkEnableOption "terminal-centric tools")
      :starship.enable (lib/mkOption {:type lib/types.bool :default true :description "Enable starship"})
      :atuin.enable    (lib/mkOption {:type lib/types.bool :default true :description "Enable atuin"})
      :zoxide.enable   (lib/mkOption {:type lib/types.bool :default true :description "Enable zoxide"})}

   :config
     (lib/mkIf config.myConfig.bundles.terminal.enable
       {:myConfig.modules.starship.enable (lib/mkDefault config.myConfig.bundles.terminal.starship.enable)
        :myConfig.modules.atuin.enable    (lib/mkDefault config.myConfig.bundles.terminal.atuin.enable)
        :myConfig.modules.zoxide.enable   (lib/mkDefault config.myConfig.bundles.terminal.zoxide.enable)})})
```

A host:

```racket
;; hosts/my-machine/configuration.bnix
#lang beagle/nix
(ns hosts.my-machine)

(module [config lib pkgs]
  {:myConfig.modules.system.stateVersion "25.05"
   :myConfig.modules.users.username "yourname"
   :myConfig.modules.users.enable true
   :myConfig.bundles.terminal.enable true
   :myConfig.bundles.development.enable true
   :myConfig.bundles.browsers.enable true})
```

Pipeline: edit `.bnix` → `firn host rebuild` runs `firn-build`
(regenerate `.nix`), then `firn-validate` (schema + type check), then
the actual `nixos-rebuild`, then tag the resulting generation. Both
files are committed because the flake reads from the git tree.

> **For editors and AI coding agents:** `.bnix` is the source-of-truth,
> `.nix` is a generated artifact. **Edit the `.bnix`, never the `.nix`**
> — the next `firn-build` overwrites direct `.nix` edits. If you're an
> AI agent reaching into this repo from another working directory, the
> CLAUDE.md auto-load probably didn't fire — read
> [`claude.md`](claude.md) first.

See [`docs/BUILDING.md`](docs/BUILDING.md) for the full DSL reference.

## CLI

`firn` is an entity-first walkable graph. Every invocation is one or
more `<node> <edge> [<leaf>]` triples, with sensible defaults when the
leaf is omitted (`all` for aggregate views, current-hostname for
host-scoped commands):

```
host    rebuild  [<host>]          firn-build → validate → nixos-rebuild → tag
host    status   [<host>]          enabled modules + bundles for a host
host    doctor   [<host>]          repo health check (untracked, stale, validator)
host    impact   [<host>]          dry-run preview: what will build, est. time
host    gen      [<host>]          current/next generation numbers
host    list     all               every host directory under hosts/

module  enable   <name>            toggle on in the default host
module  disable  <name>            toggle off
module  status   all               flat list of enabled modules
module  list     all|used|unused   list modules with optional usage filter
module  refs     <name>            show what references this module
module  add      <name>            scaffold a minimal module

bundle  enable   <name>            toggle bundle on in the default host
bundle  disable  <name>
bundle  status   <name>|all        per-bundle sub-toggle tree
bundle  list     all|used|unused
bundle  refs     <name>
bundle  add      <name>            scaffold a new (empty) bundle

repo    diff     [<target>]        re-emit Nix and diff vs committed .nix
repo    doctor   all               full repo health (5 checks)
repo    upgrade  now|dry-run       flake update + schema diff + revalidate
repo    watch    all               re-run validator on .bnix save

schema  explain  <path|err-line>   schema entry + repo references for an option
secret  list|show|edit <name>      sops list / decrypt / edit
tag     list|show|filter|index     module tag index (see docs/BUILDING.md)
platform list|show|safelist        NixOS vs darwin compatibility report
template service|submodule|home|host <name>   scaffolded skeletons
```

Walks chain — `firn module list bundle list` runs both with default
leaves. `firn` alone shows the full grid; `firn <node>` shows the edges
for that node. Legacy shapes (`firn rebuild`, `firn status`, `firn
doctor`, …) still work with a one-line deprecation pointer.

For unambiguous typo cleanup across the whole tree:

```
nisp validate --auto-fix
```

Compile the CLI to a self-contained ~1.3MB binary with
`./scripts/firn-build-bin` (installs to `~/.local/bin/firn`, ~80ms cold
start).

## The escape hatch

You will eventually want raw Nix — for an unusual `overrideAttrs`, a
build-input fixup, a vendor module shape that beagle/nix has no helper
for. Three ways down:

1. **`(raw-file ...)`** — emit a single arbitrary expression, no module
   wrapping.
2. **`(nix-ident "any.dotted.path")`** — produce a literal Nix
   identifier from a string.
3. **Just write `.nix`** — `firn-build` only rewrites files that have a
   `.bnix` source. Hand-written `.nix` modules sit alongside generated
   ones; the flake imports them the same way.

`firn repo diff` confirms hand-edited `.nix` is byte-equivalent to what
beagle would emit, which is useful when migrating modules in either
direction.

## Validation, in detail

`firn-validate` runs a multi-layer pipeline (~5 seconds total):

```
firn-validate
├── firn-lint-nix         syntax-check every generated .nix (codegen sanity)
├── auto-refresh caches   if flake.lock changed, re-cache schema + pkgs
└── beagle-validate       the main static checker:
    ├── option paths      every (set path val) against ~16k NixOS option paths
    ├── HM option paths   home-manager paths against ~3.7k HM option paths
    ├── value types       bool/str/int/path/enum/listOf/attrsOf/nullOr/submodule
    ├── enum values       literal strings checked against allowed value sets
    ├── package names     every (with-do pkgs [foo]) and pkgs.* against nixpkgs
    ├── submodule expand  lazy expansion of attrsOf-submodule children on demand
    └── duplicate detect  same option set twice in one file → flagged
```

If `beagle-validate` isn't on `BEAGLE_PATH`, the script falls back to
`nisp validate` with the same arguments. On a rebuild failure later in
the pipeline, `firn rebuild` pipes the Nix error to `claude -p` for an
instant 1-3 sentence diagnosis.

The schema cache is regenerated by `firn-extract-schema`, which calls
`nix eval` against the merged options tree of a host. The output
captures top-level type, inner element types for parameterized
containers (`listOf`, `nullOr`, `attrsOf`), submodule expansion via
`getSubOptions`, and the legal values for every `enum` — across ~16k
option paths including custom `myConfig.*` and flake-input options
(home-manager, stylix, sops, …).

The package cache is managed by `firn-extract-packages`, which
evaluates nixpkgs with the flake's overlays applied and caches
top-level attr names for the `pkgs`, `unstable`, and `master` sets.
This catches package-name typos — the single most common class of
NixOS build failure — at validation time rather than 30+ seconds into
a rebuild. The cache auto-refreshes when `flake.lock` changes.

The validator skips paths inside `home-of` / `hm-module` bodies (a
heuristic — the system schema doesn't include HM submodules), paths
containing `${…}` interpolation, and a small allowlist of HM-context
roots (`programs`, `home`, `xdg`, …). This trades some false negatives
for zero false positives — typos in those namespaces still surface at
nix-eval time.

## Schema freshness

The schema is host-specific (it's the merged options tree of one host's
nixosConfiguration) and ages relative to your `flake.lock`. The
extractor dumps the cheap top-level options once into
`.nisp-cache/schema.json` (~16k paths, a couple seconds); the
home-manager schema lives in `.nisp-cache/schema-hm.json`. Submodule
contents are *not* eagerly extracted — the validator demand-expands
only the submodules your config actually references and caches them in
`.nisp-cache/schema-submodules.json`, keyed by `flake.lock` hash +
extractor version + system. First-time references trigger a one-shot
`nix eval`; subsequent runs are pure cache hits.

Regenerate the base schema after:

- `nix flake update` (nixpkgs / flake inputs change)
- adding/changing your own `myConfig.*` options
- swapping flake inputs (e.g. adding home-manager / stylix / sops-nix)

The submodule cache invalidates automatically when the lock hash
changes — no manual step required.

## Architecture

```
.
├── flake.rkt          source-of-truth flake (still #lang nisp; compiles to flake.nix)
├── flake.nix          generated
├── modules/           atomic modules — one package/service each (NixOS)
├── bundles/           composition layer — pure module toggles (NixOS)
├── bundles-darwin/    parallel composition layer for nix-darwin hosts
├── hosts/             per-host configurations (NixOS + darwin)
├── scripts/           firn (CLI), firn-build, firn-validate, firn-extract-{schema,packages}, firn-lint-nix
├── template/          starting point for `nix flake init -t`
├── dotfiles/          out-of-store configs (live editing)
├── secrets/           sops-nix encrypted files
├── assets/            logos, screenshots
├── docs/              BUILDING.md, docs.md, MACOS.md
└── tests/             validator regression fixtures (still #lang nisp)
```

Two sibling repos provide the toolchain:

- **[`../beagle`](https://github.com/tompassarelli/beagle)** —
  `#lang beagle/nix` itself: the compiler (`beagle-build`) that turns
  `.bnix` into `.nix`, and the validator (`beagle-validate`). Override
  the clone path with `BEAGLE_PATH`.
- **[`../nisp`](https://github.com/tompassarelli/nisp)** — the older
  validation toolchain. Still used for schema extraction
  (`nisp extract-schema`), package indexing
  (`nisp extract-packages`), and the auto-fix path
  (`nisp validate --auto-fix`). Override with `NISP_PATH`.

**Module** = atom. One package or service.

**Bundle** = molecule. Pure composition. Enables a group of modules;
never installs packages directly.

Modules and bundles are auto-discovered — the flake's dynamic `imports`
walks `modules/` and `bundles/` via `builtins.readDir`. No flake edits
when adding either.

## Tradeoffs

- **Three-repo dependency.** This repo plus `../beagle` and `../nisp`.
  Bootstrap is one extra `git clone` per dependency; `BEAGLE_PATH` /
  `NISP_PATH` keep it scriptable.
- **Two-language requirement.** Authors need the basics of Racket
  s-expressions in addition to Nix concepts. The DSL surface is small
  (~30 forms) and closely mirrors Nix; the
  [BUILDING.md](docs/BUILDING.md) cheat-sheet maps every form to its
  Nix output.
- **Two artifacts per file.** Both `.bnix` and `.nix` are committed; CI
  / pre-commit hooks should run `firn repo diff` to verify they stay in
  sync. Direct `.nix` edits get overwritten on the next `firn-build`.
- **Host-specific, dated schema cache.** Tied to your `flake.lock` and
  regenerated when inputs change (see *Schema freshness*). The
  validator is unhelpful — but harmless — when the schema is stale.
- **DSL ceiling.** Some Nix idioms don't have first-class beagle/nix
  forms yet. The escape hatch (`raw-file`, hand-written `.nix`,
  `nix-ident`) is the answer; helper coverage grows as new cases turn up.

## Using FirnOS as a flake input

The [Quick start](#quick-start) above covers the `nix flake init -t`
template path. To consume FirnOS as a flake input from your own repo:

```nix
{
  inputs.firnos.url = "github:tompassarelli/firnos";
  outputs = { firnos, ... }: {
    nixosConfigurations.my-machine = firnos.lib.mkSystem {
      hostname = "my-machine";
      hostConfig = ./hosts/my-machine/configuration.nix;
      hardwareConfig = ./hosts/my-machine/hardware-configuration.nix;
    };
    # macOS:
    darwinConfigurations.my-mac = firnos.lib.mkDarwinSystem {
      hostname = "my-mac";
      hostConfig = ./hosts/my-mac/configuration.nix;
    };
  };
}
```

### `lib.mkSystem` options (NixOS)

| | required | type | default |
|---|---|---|---|
| `hostname` | yes | string | — |
| `hostConfig` | yes | path | — |
| `hardwareConfig` | yes | path | — |
| `system` | no | string | `"x86_64-linux"` |
| `extraModules` | no | list | `[]` |
| `extraOverlays` | no | list | `[]` |
| `extraSpecialArgs` | no | attrset | `{}` |

### `lib.mkDarwinSystem` options (nix-darwin)

| | required | type | default |
|---|---|---|---|
| `hostname` | yes | string | — |
| `hostConfig` | yes | path | — |
| `system` | no | string | `"aarch64-darwin"` |
| `extraModules` | no | list | `[]` |
| `extraOverlays` | no | list | `[]` |
| `extraSpecialArgs` | no | attrset | `{}` |

(No `hardwareConfig` on darwin — macOS has no analogue. See
[`docs/MACOS.md`](docs/MACOS.md) for the bootstrap walkthrough.)

## Documentation

- [docs/BUILDING.md](docs/BUILDING.md) — pipeline, DSL forms,
  validator, `firn` CLI
- [docs/docs.md](docs/docs.md) — design philosophy and conceptual primer
- [docs/MACOS.md](docs/MACOS.md) — running FirnOS on macOS via nix-darwin
- [tompassarelli/beagle](https://github.com/tompassarelli/beagle) —
  `#lang beagle/nix` itself (the compiler + validator)
- [tompassarelli/nisp](https://github.com/tompassarelli/nisp) —
  schema/package extraction + the older `#lang nisp` reference

## Inspired by

- [doomemacs/doomemacs](https://github.com/doomemacs/doomemacs) —
  opinionated convention layer + escape hatches
- [basecamp/omarchy](https://github.com/basecamp/omarchy)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [redyf/nixdots](https://github.com/redyf/nixdots)
- [eduardofuncao/nixferatu](https://github.com/eduardofuncao/nixferatu)

## License

MIT
