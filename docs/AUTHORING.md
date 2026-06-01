# Authoring config

Every `.bnix` file uses `#lang beagle/nix` and declares a namespace
matching its path. Three shapes show up repeatedly.

## A module (one package or service)

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

## A module with tag membership (the composition primitive)

Tags replace the old `bundles/` namespace. A module joins a tag by listing
it in `:tags` (default-on) or `:tags-opt-in` (opt-in-only) — there is no
separate bundle file.

```racket
;; modules/starship/default.bnix
#lang beagle/nix
(ns modules.starship)

(module [config lib pkgs]
  {:options.myConfig.modules.starship.enable
     (lib/mkEnableOption "Starship prompt")

   :tags [terminal]                    ;; auto-enabled when host enables `terminal`

   :config
     (lib/mkIf config.myConfig.modules.starship.enable
       {:programs.starship.enable true})})
```

See [TAGS.md](TAGS.md) for the full tag model — including `:tags-opt-in`
(only activates under `+name` host flags) and `:tag-overrides` (per-tag
value overrides like `firefox.default = true` under `browsers`).

## A host

```racket
;; hosts/my-machine/configuration.bnix
#lang beagle/nix
(ns hosts.my-machine)

(module [config lib pkgs]
  {:myConfig.modules.system.stateVersion "25.05"
   :myConfig.modules.users.username "yourname"
   :myConfig.modules.users.enable true})
```

Tag selection goes in a sibling file:

```racket
;; hosts/my-machine/enabled-tags.bnix
#lang beagle/nix
(ns enabled-tags)

{:enabled  [terminal development browsers]
 :disabled []}
```

## Pipeline

Edit `.bnix` → `firn host rebuild` runs:
1. `firn-build` regenerates the matching `.nix`
2. `firn-validate` schema-checks every `.bnix`
3. `nixos-rebuild switch` applies the config
4. Tag the resulting generation

Both files are committed because the flake reads from the git tree.

> **For editors and AI agents:** `.bnix` is source-of-truth, `.nix` is a
> generated artifact. **Edit the `.bnix`.** The next `firn-build`
> overwrites direct `.nix` edits.

## The escape hatch

You will eventually want raw Nix. Three ways down:

1. **`(raw-file ...)`** — emit a single arbitrary expression, no module
   wrapping.
2. **`(nix-ident "any.dotted.path")`** — produce a literal Nix
   identifier from a string.
3. **Just write `.nix`** — `firn-build` only rewrites files that have a
   `.bnix` source. Hand-written `.nix` modules sit alongside generated
   ones; the flake imports them the same way.

`firn repo diff` confirms hand-edited `.nix` is byte-equivalent to what
beagle would emit, useful when migrating in either direction.

## Migrating existing Nix to `.bnix`

`beagle-import-nix` (shipped in beagle) mechanically converts hand-written
Nix or legacy `#lang nisp` sources to `.bnix`:

```bash
beagle-import-nix path/to/configuration.rkt
```

It handles `pkg`/`svc`/`hm-module`/`module-file`/`host-file` forms. It
refuses `flake-file` — flakes have to be hand-converted (or left as-is
— `.nix` and `.bnix` coexist).

See [BUILDING.md](BUILDING.md) for the full DSL reference.
