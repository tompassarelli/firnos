# Firn

A modular, shareable NixOS configuration framework.

## What is Firn?

Firn is a NixOS configuration that you can use as a foundation for your own system. Instead of forking and dealing with merge conflicts, you import Firn as a flake input and build on top of it.

**Features:**
- 65+ modules covering desktop, development, theming, and applications
- `myConfig.*` namespace for clean, declarative configuration
- Niri window manager with Wayland support
- Stylix theming integration
- home-manager integration

## Using Firn

### Option 1: Create Your Own Config (Recommended)

Create your own repo that imports Firn:

```nix
# ~/code/my-config/flake.nix
{
  inputs.firn.url = "github:tompassarelli/firn";

  outputs = { firn, ... }: {
    nixosConfigurations.my-machine = firn.lib.mkSystem {
      hostname = "my-machine";
      hostConfig = ./hosts/my-machine/configuration.nix;
      hardwareConfig = ./hosts/my-machine/hardware-configuration.nix;
    };
  };
}
```

```nix
# ~/code/my-config/hosts/my-machine/configuration.nix
{
  myConfig.system.stateVersion = "25.05";
  myConfig.users.username = "yourname";

  myConfig.niri.enable = true;
  myConfig.kitty.enable = true;
  myConfig.fish.enable = true;
  myConfig.neovim.enable = true;
  # ... enable what you need
}
```

See [`template/`](template/) for a complete starting point.

**To update Firn:**
```bash
nix flake update firn
rebuild
```

### Option 2: Fork Directly

If you want full control, fork this repo and modify it directly. You'll manage merge conflicts yourself when pulling upstream changes.

## lib.mkSystem Options

```nix
firn.lib.mkSystem {
  hostname = "my-machine";           # Required: your hostname
  hostConfig = ./configuration.nix;  # Required: your host config
  hardwareConfig = ./hardware.nix;   # Required: hardware-configuration.nix
  system = "x86_64-linux";           # Optional: default x86_64-linux
  extraModules = [ ./my-module ];    # Optional: additional modules
  extraOverlays = [ myOverlay ];     # Optional: additional overlays
  extraSpecialArgs = { foo = 1; };   # Optional: extra args for modules
}
```

## Project Structure

```
.
├── flake.nix           # Exposes lib.mkSystem for external use
├── modules/            # All available modules (myConfig.*)
├── hosts/              # Example host configurations
├── template/           # Starting point for your own config
├── dotfiles/           # Out-of-store configs (live editing)
└── docs/               # Documentation
```

## Available Modules

Enable modules in your host config with `myConfig.<module>.enable = true`:

| Category | Modules |
|----------|---------|
| System | `boot`, `users`, `networking`, `wireguard`, `remmina`, `protonvpn`, `timezone`, `ssh`, `nix-settings`, `auto-upgrade`, `system` |
| Desktop | `niri`, `waybar`, `ironbar`, `rofi`, `walker`, `mako` |
| Hardware | `pipewire`, `bluetooth`, `input`, `wl-clipboard`, `brightnessctl`, `wl-gammarelay`, `piper`, `kanata`, `upower`, `framework`, `via`, `printing` |
| Theming | `styling`, `theming`, `gtk`, `theme-switcher` |
| Terminal | `kitty`, `fish`, `zoxide`, `atuin`, `starship` |
| Editors | `neovim`, `doom-emacs`, `lem`, `zed` |
| CLI Tools | `git`, `yazi`, `btop`, `eza`, `dust`, `tree`, `procs`, `tealdeer`, `fastfetch`, `direnv` |
| Development | `development`, `rust`, `claude`, `postgresql`, `containers`, `windows-vm` |
| Applications | `firefox`, `chrome`, `steam`, `password`, `mail` |
| Security | `polkit`, `gnome-keyring` |
| Bundles | `auth`, `development`, `productivity`, `creative`, `media` |

## Documentation

- [docs/nix-basics.md](docs/nix-basics.md) - How NixOS works, /nix/store, symlinks
- [docs/module-system.md](docs/module-system.md) - Module system deep dive
- [docs/applications.md](docs/applications.md) - Application-specific notes

## Quick Reference

**Rebuild:**
```bash
sudo nixos-rebuild switch --flake .#hostname
```

**Update dependencies:**
```bash
nix flake update
```

**Rollback:**
```bash
sudo nixos-rebuild switch --rollback
# Or select old generation from boot menu
```

## Inspired by

- [doomemacs/doomemacs](https://github.com/doomemacs/doomemacs)
- [basecamp/omarchy](https://github.com/basecamp/omarchy)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [redyf/nixdots](https://github.com/redyf/nixdots)
- [eduardofuncao/nixferatu](https://github.com/eduardofuncao/nixferatu)

## License

MIT
