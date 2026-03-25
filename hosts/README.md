# Host Configurations

Each machine gets a directory here with a `configuration.nix` that enables the modules it needs.

## Structure

```
hosts/
├── whiterabbit/          # Framework 13 laptop (primary)
│   └── configuration.nix
└── thinkpad-x1e/         # Old thinkpad
    └── configuration.nix
```

## How It Works

Host configs use the `myConfig.*` namespace to enable modules and bundles:

```nix
myConfig.niri.enable = true;
myConfig.fish.enable = true;
myConfig.development.enable = true;
myConfig.media = {
  enable = true;
  lutris.enable = false;  # opt out of individual bundle members
};
```

## Building

```bash
sudo nixos-rebuild switch --flake .#whiterabbit
```

## Adding a New Host

1. Create `hosts/new-hostname/configuration.nix`:
   ```nix
   { ... }:
   {
     myConfig.system.stateVersion = "25.05";
     myConfig.users.enable = true;
     myConfig.users.username = "yourname";
     myConfig.boot.enable = true;
     myConfig.networking.enable = true;
     # ... enable what you need
   }
   ```

2. Add a `nixosConfigurations` entry in `flake.nix`:
   ```nix
   new-hostname = self.lib.mkSystem {
     hostname = "new-hostname";
     hostConfig = ./hosts/new-hostname/configuration.nix;
     hardwareConfig = ./hosts/new-hostname/hardware-configuration.nix;
   };
   ```

Modules and bundles are auto-imported — only the host entry needs adding.
