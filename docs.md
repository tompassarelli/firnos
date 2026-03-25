# Getting Started with FirnOS

## The /nix/store: Why NixOS Is Different

On traditional Linux, you edit config files directly. On NixOS, config files are **read-only symlinks** to `/nix/store`:

```bash
ls -la /etc/nginx/nginx.conf
# lrwxrwxrwx  /etc/nginx/nginx.conf -> /nix/store/abc123-nginx.conf
```

The `/nix/store` is immutable and content-addressed — every path includes a hash of its inputs. You write `.nix` files, Nix evaluates them into store paths, and the system symlinks to those paths. This makes your system declarative, reproducible, atomic, and rollbackable.

```
You write:       ~/code/nixos-config/*.nix
                           ↓  (nix evaluates)
Nix generates:   /nix/store/hash-config
                           ↓  (creates symlink)
System uses:     /etc/thing -> /nix/store/hash-config
```

## The Abstraction Spectrum

There's a spectrum of how people organize NixOS configs. Each level solves a real problem but introduces new ones:

**Single file** — everything in one `configuration.nix`. Simple, but becomes a mess at 500+ lines. No way to share config between machines.

**Split files with imports** — organized by topic, comment out what you don't need. Better, but commenting/uncommenting is tedious and error-prone.

**Custom modules with enable flags** — declare a `myConfig.*` namespace with `mkEnableOption`. Host configs become a clean list of enables. Composable and shareable, but more boilerplate per module.

**Flakes** — pin dependencies with a lockfile, manage multiple hosts from one repo. Reproducible builds across machines. More complexity upfront but pays off immediately with multi-host setups.

Each level builds on the previous. You can mix them — flakes for infrastructure, custom modules for your features, raw NixOS options where they make sense.

## What FirnOS Chose

FirnOS sits at the top of that spectrum with two namespaces:

**`myConfig.modules.*`** = atoms. One package or service each. Always `modules/<name>/{default.nix, <name>.nix}`.

**`myConfig.bundles.*`** = molecules. Pure composition — groups modules under one toggle. Never installs packages directly. Each module in a bundle can be individually disabled:

```nix
myConfig.bundles.media = {
  enable = true;           # turns on 13 modules
  lutris.enable = false;   # except this one
};
```

This works through NixOS priorities: bundles propagate enables with `mkDefault` (priority 1000), so a direct `false` (priority 100) always wins.

**Auto-import**: `flake.nix` discovers all modules and bundles from directory listings. Adding a new module = create the directory and `git add`. No flake.nix edits.

See [`template/`](template/) for a complete starting config to copy.

## Adding a New Host

1. Create `hosts/new-hostname/configuration.nix`:
   ```nix
   { ... }:
   {
     myConfig.modules.system.stateVersion = "25.05";
     myConfig.modules.users.enable = true;
     myConfig.modules.users.username = "yourname";
     myConfig.modules.boot.enable = true;
     myConfig.modules.networking.enable = true;
     myConfig.bundles.development.enable = true;
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

## mkOutOfStoreSymlink: Live-Editing Configs

For configs you actively iterate on — keybinds, editor settings, window manager tweaks — FirnOS symlinks directly to your dotfiles instead of going through the store:

```nix
xdg.configFile."niri/config.kdl".source =
  config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/code/nixos-config/dotfiles/niri/config.kdl";
```

**Through the store**: source → `/nix/store/hash` → `~/.config/niri/config.kdl` — read-only, requires rebuild to change.

**Out-of-store**: source → `~/.config/niri/config.kdl` — editable, changes take effect immediately, still version controlled in your repo.

Use the store for generated or rarely-changed config. Use out-of-store symlinks for everything you hand-write and tweak.

## Git + NixOS Generations

Every `nixos-rebuild switch` creates a new **generation** — a bootable snapshot of your system. You have three independent layers of safety:

1. **Git history** — your config source
2. **NixOS generations** — built system snapshots, selectable from the boot menu
3. **Btrfs snapshots** — filesystem-level rollback (optional)

**Key gotcha**: booting into an old generation does NOT change your git state. The generation runs the old *built* system, but your source files stay at the current commit. Running `rebuild` always builds from the current source.

| Problem | Solution |
|---------|----------|
| Config broke | `git checkout <good-commit>` + rebuild |
| System won't boot | Boot menu → select old generation |
| Deleted files | Btrfs snapshot restore |

Commit after every successful rebuild to keep git history synchronized with generations.
