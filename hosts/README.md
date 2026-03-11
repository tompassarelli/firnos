# Host Configurations

This directory contains host-specific configurations for each machine in your NixOS fleet.

## Structure

```
hosts/
├── whiterabbit/          # Framework laptop
│   └── configuration.nix
├── thinkpad-x1e/         # old thinkpad
│   └── configuration.nix
└── README.md
```

## How It Works

Firn uses a **flat namespace** for modules:

```nix
myConfig.niri.enable = true;
myConfig.git.enable = true;
myConfig.boot.enable = true;
myConfig.users.username = "tom";
myConfig.theming.chosenTheme = "tokyo-night-dark";
```

Everything is set in your host's `configuration.nix` — username, theme, which modules to enable.

## Building a Specific Host

```bash
# Build whiterabbit (Framework laptop)
sudo nixos-rebuild switch --flake .#whiterabbit

# Build thinkpad-x1e (Thinkpad laptop)
sudo nixos-rebuild switch --flake .#thinkpad-x1e
```

## Adding a New Host

1. Create directory: `mkdir -p hosts/new-hostname`
2. Create config: `hosts/new-hostname/configuration.nix`
   ```nix
   { ... }:
   {
     myConfig.system.stateVersion = "25.05";
     myConfig.users.enable = true;
     myConfig.users.username = "yourname";
     myConfig.boot.enable = true;
     myConfig.networking.enable = true;
     myConfig.theming.chosenTheme = "tokyo-night-dark";
     # ... enable what you need
   }
   ```
3. Add to `flake.nix`:
   ```nix
   nixosConfigurations = {
     new-hostname = self.lib.mkSystem {
       hostname = "new-hostname";
       hostConfig = ./hosts/new-hostname/configuration.nix;
       hardwareConfig = ./hosts/new-hostname/hardware-configuration.nix;
     };
   };
   ```

## Host-Specific Examples

### Framework Laptop (whiterabbit)
- Framework-specific hardware support
- Auto-upgrade enabled (for travel)
- Full development setup (Zed, Neovim, Doom Emacs)
- Power management optimized

### Old Laptop (thinkpad-x1e)
- Custom keyboard (VIA enabled)
- Steam and game development tools
- Manual updates (no auto-upgrade)
- Bevy game engine libraries

## Module Enable/Disable Philosophy

Each host configuration is a **declarative list of enabled features**:

```nix
# Example: Minimal server config
{ ... }:
{
  myConfig.system.stateVersion = "25.05";
  myConfig.users.enable = true;
  myConfig.users.username = "yourname";
  myConfig.boot.enable = true;
  myConfig.networking.enable = true;
  myConfig.ssh.enable = true;
  myConfig.kitty.enable = true;
  myConfig.fish.enable = true;
}
```

This makes it easy to see at a glance what each machine does.
