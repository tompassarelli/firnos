# FirnOS

A modular, shareable NixOS configuration framework.

## What is FirnOS?

FirnOS is a NixOS configuration you can use as a foundation for your own system. Import it as a flake input and build on top of it.

**Features:**
- 113 modules + 5 bundles covering desktop, development, theming, and applications
- `myConfig.*` namespace for clean, declarative configuration
- Niri window manager with Wayland support
- Stylix theming integration
- home-manager integration

## Using FirnOS

### Option 1: Create Your Own Config (Recommended)

Create your own repo that imports FirnOS:

```nix
# ~/code/my-config/flake.nix
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

### Option 2: Fork Directly

Fork this repo and modify it directly. You'll manage merge conflicts yourself when pulling upstream changes.

## lib.mkSystem Options

```nix
firnos.lib.mkSystem {
  hostname = "my-machine";           # Required: your hostname
  hostConfig = ./configuration.nix;  # Required: your host config
  hardwareConfig = ./hardware.nix;   # Required: hardware-configuration.nix
  system = "x86_64-linux";           # Optional: default x86_64-linux
  extraModules = [ ./my-module ];    # Optional: additional modules
  extraOverlays = [ myOverlay ];     # Optional: additional overlays
  extraSpecialArgs = { foo = 1; };   # Optional: extra args for modules
}
```

## Architecture

```
.
├── flake.nix           # Exposes lib.mkSystem, auto-discovers modules + bundles
├── modules/            # Atomic modules (one feature each)
├── bundles/            # Bundles (compose modules under one toggle)
├── hosts/              # Host-specific configurations
├── template/           # Starting point for your own config
├── dotfiles/           # Out-of-store configs (live editing)
└── docs/               # Documentation
```

**Module** = atom. One package or feature. `modules/<name>/{default.nix, <name>.nix}`.

**Bundle** = molecule. Pure composition. Enables a group of modules, never installs packages directly. Each module in a bundle can be individually toggled:

```nix
# Enable the whole media bundle
myConfig.media.enable = true;

# But opt out of one module
myConfig.media = {
  enable = true;
  lutris.enable = false;
};
```

Modules and bundles are auto-imported from directory listings — adding a new one is just creating the directory. No `flake.nix` edits needed.

## Modules

Enable with `myConfig.<module>.enable = true` in your host config.

| Category | Modules |
|----------|---------|
| System | `boot`, `users`, `networking`, `wireguard`, `remmina`, `protonvpn`, `timezone`, `ssh`, `nix-settings`, `auto-upgrade`, `system` |
| Desktop | `niri`, `waybar`, `quickshell`, `ironbar`, `rofi`, `walker`, `mako`, `upower` |
| Hardware | `pipewire`, `bluetooth`, `input`, `wl-clipboard`, `brightnessctl`, `wl-gammarelay`, `piper`, `kanata`, `glide`, `framework`, `via`, `printing` |
| Auth | `polkit`, `gnome-keyring`, `password` |
| Theming | `styling`, `theming`, `gtk`, `theme-switcher` |
| Terminal | `kitty`, `fish`, `zoxide`, `atuin`, `starship` |
| Editors | `neovim`, `doom-emacs`, `lem`, `zed`, `vim` |
| CLI Tools | `git`, `yazi`, `btop`, `eza`, `dust`, `tree`, `procs`, `tealdeer`, `fastfetch`, `direnv`, `ripgrep`, `fd`, `delta` |
| Dev Tools | `claude`, `rust`, `nodejs`, `python`, `sqlite`, `dbeaver`, `gh`, `imagemagick`, `postgresql`, `sqlcmd`, `dotnet`, `containers`, `mini-serve` |
| Utilities | `wget`, `curl`, `unzip`, `unrar`, `parted`, `pandoc`, `hugo`, `ffmpeg` |
| Browsers | `firefox`, `chrome`, `nyxt`, `ladybird` |
| Media | `discord`, `zoom`, `spotify`, `youtube-music`, `imv`, `mpv`, `zathura`, `pavucontrol` |
| Creative | `godot`, `blender`, `gimp`, `obs-studio`, `wf-recorder`, `slurp`, `eyedropper` |
| Productivity | `obsidian`, `todoist`, `pomodoro`, `rustdesk`, `slack` |
| Desktop Tools | `nautilus`, `swaylock`, `grim` |
| Gaming | `steam`, `lutris` |
| Mail | `mail` |
| Virtualization | `windows-vm` |

## Bundles

Bundles group modules under one toggle. All modules default to enabled; override individually.

| Bundle | Modules included |
|--------|-----------------|
| `auth` | `polkit`, `gnome-keyring` |
| `development` | `vim`, `claude`, `ripgrep`, `fd`, `unzip`, `parted`, `wget`, `curl`, `imagemagick`, `nodejs`, `python`, `sqlite`, `dbeaver`, `gh`, `delta` |
| `creative` | `godot`, `blender`, `gimp`, `obs-studio`, `wf-recorder`, `slurp`, `ffmpeg`, `eyedropper` |
| `media` | `discord`, `zoom`, `spotify`, `youtube-music`, `imv`, `mpv`, `zathura`, `lutris`, `nautilus`, `swaylock`, `grim`, `slurp`, `pavucontrol` |
| `productivity` | `obsidian`, `todoist`, `pomodoro`, `rustdesk`, `unrar`, `slack`, `hugo`, `pandoc` |

## Documentation

- [docs/nix-basics.md](docs/nix-basics.md) - Getting started: the store, abstraction spectrum, what FirnOS chose

## Quick Reference

```bash
# Rebuild
sudo nixos-rebuild switch --flake .#hostname

# Update dependencies
nix flake update

# Rollback
sudo nixos-rebuild switch --rollback
```

## Inspired by

- [doomemacs/doomemacs](https://github.com/doomemacs/doomemacs)
- [basecamp/omarchy](https://github.com/basecamp/omarchy)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [redyf/nixdots](https://github.com/redyf/nixdots)
- [eduardofuncao/nixferatu](https://github.com/eduardofuncao/nixferatu)

## License

MIT
