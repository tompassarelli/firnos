# FirnOS User Config Template

This is a starting point for your own NixOS configuration powered by [FirnOS](https://github.com/tompassarelli/firnos).

## Quick Start

1. **Copy this template** to your own repo:
   ```bash
   mkdir ~/code/my-nixos-config
   cp -r /path/to/firnos/template/* ~/code/my-nixos-config/
   cd ~/code/my-nixos-config
   git init
   ```

2. **Copy your hardware configuration**:
   ```bash
   cp /etc/nixos/hardware-configuration.nix hosts/my-machine/
   ```

3. **Rename your host** (replace "my-machine" with your hostname):
   ```bash
   mv hosts/my-machine hosts/yourhostname
   ```
   Then update `flake.nix` to match.

4. **Edit your configuration**:
   ```bash
   nvim hosts/yourhostname/configuration.nix
   ```
   - Set `myConfig.users.username` to your username
   - Enable/disable modules as needed

5. **Build and switch**:
   ```bash
   sudo nixos-rebuild switch --flake .#yourhostname
   ```

## Updating FirnOS

To pull the latest changes from upstream FirnOS:

```bash
nix flake update firnos
sudo nixos-rebuild switch --flake .#yourhostname
```

## Adding Your Own Modules

Create a `modules/` directory and add your custom modules:

```nix
# modules/my-module/default.nix
{ config, lib, ... }:
{
  options.myCustom.thing.enable = lib.mkEnableOption "my thing";

  config = lib.mkIf config.myCustom.thing.enable {
    # Your config here
  };
}
```

Then add it to your flake:

```nix
extraModules = [ ./modules/my-module ];
```

## Adding Overlays

```nix
extraOverlays = [
  (final: prev: {
    my-package = prev.my-package.override { ... };
  })
];
```

## Multiple Machines

Add more entries to `nixosConfigurations`:

```nix
nixosConfigurations = {
  laptop = firnos.lib.mkSystem { ... };
  desktop = firnos.lib.mkSystem { ... };
  server = firnos.lib.mkSystem { ... };
};
```
