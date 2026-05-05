<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/firnos-logo.png" width="150">
    <source media="(prefers-color-scheme: light)" srcset="assets/firnos-logo-dark.png" width="150">
    <img alt="FirnOS" src="assets/firnos-logo.png" width="150">
  </picture>
</p>

**A source-aware NixOS config compiler.** Write your config in a small
Racket DSL ([nisp](https://github.com/tompassarelli/nisp)); validate
every option path, type, and enum value against the NixOS options
schema; emit ordinary Nix.

Both `.rkt` and `.nix` are committed. The flake reads regular generated
Nix. You're not trapped in a custom language — you can drop down to raw
Nix at any point, and you can stop using FirnOS by deleting the `.rkt`
files.

## What the checker catches

```
$ firn rebuild
modules/printing/default.rkt:6:7: unknown option services.pipwire.alsa.enable
  did you mean: services.pipewire.alsa.enable or services.pipewire.pulse.enable?
modules/foo/default.rkt:9:34: type mismatch at services.openssh.enable:
  expected bool, got string
hosts/laptop/configuration.rkt:11:47: type mismatch at boot.loader.systemd-boot.consoleMode:
  "atuo" not in enum {"0", "1", "2", "5", "auto", "max", "keep"} — did you mean "auto"?
```

`file:line:col` precision **on the value, not the path**, with did-you-mean
suggestions, before `nixos-rebuild` runs. That's the whole pitch.

## What it is

Three pieces on top of the standard NixOS module system:

- **nisp** — a Racket `#lang` for writing NixOS config as s-expressions. Compiles to ordinary Nix.
- **firn-validate** — a static checker that walks every nisp `.rkt`, looks up each option path against the cached NixOS options schema (~16k paths), and type-checks values for bool/str/int/listOf/nullOr/enum/path mismatches.
- **firn** — a CLI that wraps the daily workflow: rebuild, enable/disable, scaffolding, secrets, watch.

Plus the framework conventions: `myConfig.modules.*` for atomic
packages/services, `myConfig.bundles.*` for composable groups, directory
auto-discovery — adding a module is just creating a directory.

## Why this works

NixOS already validates option paths and types — but it does so during
module evaluation, after the original authoring context has been
discarded. By the time an error surfaces, the line that caused it is
several layers of `mkIf`/`mkMerge`/import indirection away. The error
message points at where the option got *forced*, not where the typo was
*written*.

FirnOS validates at a different layer. The nisp AST is a concrete data
structure in memory before any Nix is emitted. We walk it, extract every
`(set 'PATH val)` and `(enable 'PATH)`, look the path up in the cached
schema (exported once via `nix eval` against the options tree), and
report mismatches with `file:line:col` from the original `.rkt` source.

The result: typo and type errors surface at the line you wrote, in
milliseconds, before any `nixos-rebuild` evaluation cost.

## Quick start

```bash
git clone https://github.com/tompassarelli/firnos
git clone https://github.com/tompassarelli/nisp           # sibling clone, firn-build expects ../nisp
cd firnos
cp /etc/nixos/hardware-configuration.nix hosts/my-machine/
# edit hosts/my-machine/configuration.rkt — set username, enable bundles
firn rebuild   # firn-build → firn-validate → nixos-rebuild → tag generation
```

On macOS, see [`docs/MACOS.md`](docs/MACOS.md) — FirnOS supports nix-darwin via `lib.mkDarwinSystem` with a curated subset of modules.

## Authoring config

A trivial install-package module:

```racket
;; modules/vim/default.rkt
#lang nisp
(pkg vim "Vim text editor")
```

A bundle that toggles a list of children:

```racket
;; bundles/development/default.rkt
#lang nisp
(bundle-file development
  (desc "core development workflow")
  (sub-modules git gh delta vim claude direnv containers ripgrep fd))
```

A host config:

```racket
;; hosts/my-machine/configuration.rkt
#lang nisp
(host-file
  (set myConfig.modules.system.stateVersion "25.05")
  (set myConfig.modules.users.username "yourname")
  (enable myConfig.bundles.terminal
          myConfig.bundles.development
          myConfig.bundles.browsers))
```

The pipeline: edit `.rkt` → `firn rebuild` regenerates the `.nix`,
validates, builds, and tags the resulting generation. Both files are
committed (the flake reads from the git tree).

See [`docs/BUILDING.md`](docs/BUILDING.md) for the full DSL reference.

## CLI

```
firn rebuild [host] [--skip-checks]   firn-build → validate → nixos-rebuild → tag
firn watch                            re-run validator on .rkt save
firn enable  <name> [host]            toggle a module/bundle on in the host config
firn disable <name> [host]            toggle off
firn status  [host]                   list enabled modules/bundles
firn list   [--used | --unused]       list modules/bundles, usage filter
firn refs    <name>                   show what references a module/bundle
firn diff    [target...]              re-emit Nix and diff vs committed .nix
firn mod     <name>                   scaffold a minimal module
firn bundle  <name> <mods...>         scaffold a new bundle
firn scaffold <pat> <name>            template (service|submodule|home|host)
firn explain <path | err-line>        schema entry + repo references for an option
firn doctor                           repo health check (untracked, stale, validator)
firn upgrade [--dry-run]              flake update + schema diff + flag deprecated paths
firn secret  <name|list|show>         sops edit / list / decrypt
firn gen                              current/next generation numbers
```

For unambiguous typo cleanup across the whole tree:

```
nisp-validate --auto-fix               rewrite unambiguous typos in place
```

Compile to a self-contained ~1.3MB binary with `./scripts/firn-build-bin`
(installs to `~/.local/bin/firn`, ~80ms cold start).

## The escape hatch

You will eventually want raw Nix — for an unusual `overrideAttrs`, a
build-input fixup, vendor module shape that doesn't fit nisp's helpers.
There are three ways down:

1. **`(raw-file ...)`** — emit a single arbitrary expression, no module wrapping.
2. **`(nix-ident "any.dotted.path")`** — produce a literal Nix identifier from a string.
3. **Just write `.nix`** — `firn-build` only rewrites `.rkt` files. Hand-written `.nix` modules sit alongside generated ones; the flake imports them the same way.

`firn diff` confirms hand-edited `.nix` is byte-equivalent to what nisp
would emit, which is useful when migrating modules in either direction.

## Validation, in detail

`firn-validate` runs two passes against `.firn-build/schema.json`:

- **Pass 1** — every `(set …)` and `(enable …)` path checked for existence. Levenshtein-based did-you-mean.
- **Pass 2** — for known paths, statically infer the value's shape and check it against the schema's expected type. Catches bool/str/int/listOf/nullOr/enum/path/float mismatches. Enum violations get did-you-mean against the allowed values.

The schema cache is regenerated by `firn-extract-schema`, which calls
`nix eval` against the merged options tree of a host. Output captures
the full type tree — top-level type, inner element types for
parameterized containers (`listOf`, `nullOr`, `attrsOf`), submodule
expansion via `getSubOptions`, and the legal values for every `enum` —
across ~16k option paths including custom `myConfig.*` and flake-input
options (home-manager, stylix, sops, …).

The validator skips paths inside `home-of` / `hm-module` bodies (a
heuristic — the system schema doesn't include HM submodules), paths with
`${…}` interpolation, and a small allowlist of HM-context roots
(`programs`, `home`, `xdg`, …). This trades some false negatives for
zero false positives — typos in those namespaces still surface at
nix-eval time.

## Schema freshness

The schema is host-specific (it's the merged options tree of one host's
nixosConfiguration) and ages relative to your `flake.lock`. The
extractor dumps the cheap top-level options once into
`.firn-build/schema.json` (~16k paths, a couple seconds). Submodule
contents are *not* eagerly extracted — the validator demand-expands
only the submodules your config actually references and caches them in
`.firn-build/schema-submodules.json`, keyed by `flake.lock` hash +
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
├── flake.rkt          source-of-truth flake (compiles to flake.nix)
├── nisp/              the DSL itself (#lang nisp implementation)
├── modules/           atomic modules — one package/service each
├── bundles/           composition layer — pure module toggles, no packages
├── hosts/             per-host configurations
├── scripts/           firn (CLI), firn-build, firn-validate, firn-extract-schema
├── template/          starting point for `nix flake init -t`
├── dotfiles/          out-of-store configs (live editing)
└── docs/              BUILDING.md, docs.md, MACOS.md
```

**Module** = atom. One package or service.

**Bundle** = molecule. Pure composition. Enables a group of modules,
never installs packages directly.

Modules and bundles are auto-discovered — the flake's dynamic `imports`
walks `modules/` and `bundles/` via `builtins.readDir`. No flake edits
needed when adding either.

## Tradeoffs

- **Two-language requirement.** Authors need the basics of Racket s-expressions in addition to Nix concepts. The DSL is small (~30 forms) and the surface vocabulary closely mirrors Nix; the [BUILDING.md](docs/BUILDING.md) cheat-sheet maps every form to its Nix output.

- **Two artifacts per file.** Both `.rkt` and `.nix` are committed; CI / pre-commit hooks should run `firn diff` to ensure they stay in sync. Generated `.nix` is gitignored from manual edits in the typical workflow.

- **Schema cache is host-specific and dated.** It's tied to your flake.lock and regenerated when inputs change (see *Schema freshness* above). The validator is unhelpful — but harmless — when the schema is stale.

- **DSL ceiling exists.** Some Nix idioms don't have first-class nisp forms yet. The escape hatch (`raw-file`, hand-written `.nix`, direct `nix-ident`) is the answer; the helper coverage grows as we encounter cases.

## Using FirnOS in your own repo

### Option 1: bootstrap from template

```bash
nix flake init -t github:tompassarelli/firnos
```

### Option 2: import from your flake

```nix
{
  inputs.firnos.url = "github:tompassarelli/firnos";
  outputs = { firnos, ... }: {
    nixosConfigurations.my-machine = firnos.lib.mkSystem {
      hostname = "my-machine";
      hostConfig = ./hosts/my-machine/configuration.nix;
      hardwareConfig = ./hosts/my-machine/hardware-configuration.nix;
    };
  };
}
```

### `lib.mkSystem` options

| | required | type | default |
|---|---|---|---|
| `hostname` | yes | string | — |
| `hostConfig` | yes | path | — |
| `hardwareConfig` | yes | path | — |
| `system` | no | string | `"x86_64-linux"` |
| `extraModules` | no | list | `[]` |
| `extraOverlays` | no | list | `[]` |
| `extraSpecialArgs` | no | attrset | `{}` |

## Documentation

- [docs/BUILDING.md](docs/BUILDING.md) — pipeline, DSL forms, validator, firn CLI
- [docs/docs.md](docs/docs.md) — design philosophy and conceptual primer
- [docs/MACOS.md](docs/MACOS.md) — running FirnOS on macOS via nix-darwin
- [tompassarelli/nisp](https://github.com/tompassarelli/nisp) — `#lang nisp` reference (the DSL itself)

## Inspired by

- [doomemacs/doomemacs](https://github.com/doomemacs/doomemacs) — opinionated convention layer + escape hatches
- [basecamp/omarchy](https://github.com/basecamp/omarchy)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [redyf/nixdots](https://github.com/redyf/nixdots)
- [eduardofuncao/nixferatu](https://github.com/eduardofuncao/nixferatu)

## License

MIT
