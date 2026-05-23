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

## A bundle (pure composition with per-child opt-out)

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

## A host

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

It handles `pkg`/`svc`/`hm-module`/`module-file`/`bundle-file`/`host-file`
forms. It refuses `flake-file` — flakes have to be hand-converted (or
left as-is — `.nix` and `.bnix` coexist).

See [BUILDING.md](BUILDING.md) for the full DSL reference.
