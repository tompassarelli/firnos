<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/firnos-logo.png" width="150">
    <source media="(prefers-color-scheme: light)" srcset="assets/firnos-logo-dark.png" width="150">
    <img alt="FirnOS" src="assets/firnos-logo.png" width="150">
  </picture>
</p>

<p align="center">A coherent Nix workstation, compressed by deadlines</p>

## What is FirnOS?

A NixOS configuration framework. 139 atomic modules, 18 bundles. Import it as a flake input and build on top of it.

- `myConfig.modules.*` for individual packages/services
- `myConfig.bundles.*` for composed groups with per-module overrides
- Auto-discovery — add a module by creating a directory
- Niri + Wayland, Stylix theming, home-manager

## Quick Start

```bash
nix flake init -t github:tompassarelli/firnos
```

Then edit `hosts/my-machine/configuration.nix`, copy your `hardware-configuration.nix` in, and build:

```bash
sudo nixos-rebuild switch --flake .#my-machine
```

## Using FirnOS

### Option 1: Bootstrap with Template (Recommended)

```bash
mkdir ~/code/my-config && cd ~/code/my-config
nix flake init -t github:tompassarelli/firnos
cp /etc/nixos/hardware-configuration.nix hosts/my-machine/
# Edit hosts/my-machine/configuration.nix — set username, enable what you need
sudo nixos-rebuild switch --flake .#my-machine
```

### Option 2: Import from Your Own Flake

```nix
# flake.nix
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

### Option 3: Fork Directly

Fork this repo and modify it directly. You'll manage merge conflicts yourself when pulling upstream changes.

## Host Config Example

```nix
{
  myConfig.modules.system.stateVersion = "25.05";
  myConfig.modules.users.username = "yourname";

  # Bundles — groups of modules, individually overridable
  myConfig.bundles.terminal.enable = true;
  myConfig.bundles.development.enable = true;
  myConfig.bundles.browsers = {
    enable = true;
    firefox.fennec.enable = true;
  };
  myConfig.bundles.media = {
    enable = true;
    lutris.enable = false;  # everything except this
  };

  # Modules — individual features
  myConfig.modules.niri.enable = true;
  myConfig.modules.git.enable = true;
  myConfig.modules.neovim.enable = true;
}
```

## Architecture

```
.
├── flake.nix           # Exposes lib.mkSystem, auto-discovers modules + bundles
├── modules/            # Atomic modules (one package/service each)
├── bundles/            # Bundles (compose modules under one toggle)
├── hosts/              # Host-specific configurations
├── template/           # Starting point (used by nix flake init -t)
└── dotfiles/           # Out-of-store configs (live editing)
```

**Module** = atom. One package or service. `modules/<name>/{default.nix, <name>.nix}`.

**Bundle** = molecule. Pure composition. Enables a group of modules, never installs packages directly. Each module in a bundle can be individually toggled.

Modules and bundles are auto-imported from directory listings — adding a new one is just creating the directory. No `flake.nix` edits needed.

## CLI Tools

`firn` is the CLI for managing your config — modules, bundles, secrets, rebuilds. Run `firn` with no args to see all commands.

## lib.mkSystem Options

```nix
firnos.lib.mkSystem {
  hostname = "my-machine";           # Required
  hostConfig = ./configuration.nix;  # Required
  hardwareConfig = ./hardware.nix;   # Required
  system = "x86_64-linux";           # Optional: default x86_64-linux
  extraModules = [ ./my-module ];    # Optional
  extraOverlays = [ myOverlay ];     # Optional
  extraSpecialArgs = { foo = 1; };   # Optional
}
```

## Documentation

- [docs.md](docs.md) - Getting started: the store, abstraction spectrum, what FirnOS chose

## Inspired by

- [doomemacs/doomemacs](https://github.com/doomemacs/doomemacs)
- [basecamp/omarchy](https://github.com/basecamp/omarchy)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [redyf/nixdots](https://github.com/redyf/nixdots)
- [eduardofuncao/nixferatu](https://github.com/eduardofuncao/nixferatu)

## License

MIT
