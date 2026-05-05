<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/firnos-logo.png" width="150">
    <source media="(prefers-color-scheme: light)" srcset="assets/firnos-logo-dark.png" width="150">
    <img alt="FirnOS" src="assets/firnos-logo.png" width="150">
  </picture>
</p>

## What is FirnOS?

A NixOS configuration framework with three load-bearing pieces beyond the
usual module-based config:

- **nisp** — a custom Racket `#lang` for writing config as s-expressions; compiles to Nix.
- **firn-validate** — schema-aware validator that catches NixOS option typos at the `.rkt` source line, before `nixos-rebuild` ever runs.
- **firn** — Racket-based CLI that wraps the routine workflow (rebuild, enable/disable, scaffolding, secrets).

Plus the framework conventions: `myConfig.modules.*` for individual
packages/services, `myConfig.bundles.*` for composable groups,
auto-discovery — add a directory to register a module.

## Quick start

```bash
nix flake init -t github:tompassarelli/firnos
cp /etc/nixos/hardware-configuration.nix hosts/my-machine/
# edit hosts/my-machine/configuration.rkt — set username, enable what you need
./scripts/firn-build
sudo nixos-rebuild switch --flake .#my-machine
```

## Authoring config

A trivial install-package module is one line:

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

Edit `.rkt`, run `./scripts/firn-build` to regenerate `.nix`, then
`nixos-rebuild`. Both files are committed (the flake reads from the git
tree). See [`docs/BUILDING.md`](docs/BUILDING.md) for full DSL reference.

## CLI

```
firn rebuild [host]            nixos-rebuild + tag the resulting generation
firn enable <name>  [host]     toggle a module/bundle on in the host config
firn disable <name> [host]     toggle off
firn status [host]             list enabled modules/bundles
firn list [--used | --unused]
firn refs <name>               show what references a module/bundle
firn mod <name>                scaffold a new module (.rkt)
firn bundle <name> <mods...>   scaffold a new bundle (.rkt)
firn secret <name|list|show>   sops edit / list / decrypt
firn gen                       current and next generation numbers
```

Compile to a self-contained binary with `./scripts/firn-build-bin`
(installs to `~/.local/bin/firn`).

## Validation

```
$ ./scripts/firn-validate
modules/printing/default.rkt:6:7: unknown option services.pipwire.alsa.enable
  did you mean: services.pipewire.alsa.enable or services.pipewire.pulse.enable?
```

Schema is extracted by `./scripts/firn-extract-schema` (re-run after
`nix flake update` or after changing your own modules' options). Validator
walks every `(set …)` and `(enable …)` against the cached NixOS options
tree (~16k paths including custom `myConfig.*` and flake-input options).

## Architecture

```
.
├── flake.rkt          # Source-of-truth flake (compiles to flake.nix)
├── nisp/              # The DSL implementation (#lang nisp)
├── modules/           # Atomic modules (one package/service each)
├── bundles/           # Bundles (compose modules under one toggle)
├── hosts/             # Host-specific configurations
├── scripts/           # firn, firn-build, firn-validate, firn-extract-schema
├── template/          # Starting point for `nix flake init -t`
├── dotfiles/          # Out-of-store configs (live editing)
└── docs/              # BUILDING.md, nisp.md, docs.md
```

**Module** = atom. One package or service. `modules/<name>/default.rkt`.

**Bundle** = molecule. Pure composition. Enables a group of modules; never
installs packages directly. Sub-modules can be individually toggled.

Modules and bundles are auto-discovered — adding a new one is just creating
the directory + `.rkt`. The flake's dynamic `imports` finds them via
`builtins.readDir`. No flake edits needed.

## Using FirnOS in your own repo

### Option 1: bootstrap from template (recommended)

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

- [docs/BUILDING.md](docs/BUILDING.md) — pipeline, DSL conventions, validator, firn CLI
- [docs/nisp.md](docs/nisp.md) — `#lang nisp` reference
- [docs/docs.md](docs/docs.md) — design philosophy, abstraction spectrum

## Inspired by

- [doomemacs/doomemacs](https://github.com/doomemacs/doomemacs)
- [basecamp/omarchy](https://github.com/basecamp/omarchy)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [redyf/nixdots](https://github.com/redyf/nixdots)
- [eduardofuncao/nixferatu](https://github.com/eduardofuncao/nixferatu)

## License

MIT
