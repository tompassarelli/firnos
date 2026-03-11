# NixOS Basics: Store, Symlinks, and Configuration Evolution

## How NixOS Actually Works: The /nix/store

### You Can't Just Edit /etc

On traditional Linux, you edit config files directly:
```bash
sudo vim /etc/nginx/nginx.conf  # Edit the file
sudo systemctl restart nginx    # Apply changes
```

On NixOS, **you literally cannot do this**:

```bash
ls -la /etc/nginx/nginx.conf
# Output:
lrwxrwxrwx  /etc/nginx/nginx.conf -> /nix/store/abc123-nginx.conf
```

It's a **read-only symlink** to `/nix/store`.

### The /nix/store: Immutable and Content-Addressed

The `/nix/store` is:

- **Immutable**: Files cannot be modified after creation
- **Content-addressed**: Each file has a hash based on its inputs
- **Shared**: Multiple configurations can share identical files

Example:
```bash
/nix/store/abc123xyz-nginx.conf
           ^^^^^^
           Hash of: source code + dependencies + build inputs
```

### How Configuration Actually Flows

```
1. You write:                    ~/code/nixos-config/*.nix
                                          ↓
                                   (nix evaluates)
                                          ↓
2. Nix generates:                /nix/store/hash-nginx.conf
                                          ↓
                                   (creates symlink)
                                          ↓
3. System uses:                  /etc/nginx/nginx.conf -> /nix/store/hash-nginx.conf
```

### What Happens on nixos-rebuild switch

```bash
sudo nixos-rebuild switch
```

1. **Evaluates** your `.nix` files
2. **Builds** any packages needed
3. **Generates** all config files → `/nix/store`
4. **Creates symlinks** from `/etc` → `/nix/store`
5. **Activates** new configuration (switches systemd units, restarts services)
6. **Updates boot entry** (so next boot uses this config)

### Why This Design?

#### Declarative
Your entire system state is in `.nix` files, not scattered across `/etc`

#### Reproducible
Same `.nix` files = identical `/nix/store` outputs = identical system

#### Atomic
Switch configurations atomically. If it fails, nothing changes.

#### Rollbackable
Old configs stay in `/nix/store`. Boot into previous generation anytime.

#### Auditable
Can't have "mystery edits" to `/etc`. Everything comes from your `.nix` files.

### Example: Your Fish Config

```bash
ls -la ~/.config/fish/config.fish

# Output:
lrwxrwxrwx config.fish -> /nix/store/xyz789-hm-session-vars.fish
```

The file itself says:
```fish
# DO NOT EDIT -- this file has been generated automatically by home-manager.
```

Why? Because:
1. You declared fish config in `modules/fish/fish.nix`
2. home-manager evaluated it
3. Generated config → `/nix/store/xyz789-hm-session-vars.fish`
4. Symlinked `.config/fish/config.fish` → store

If you edit it manually, next `nixos-rebuild` overwrites it.

### Exception to the Rule: mkOutOfStoreSymlink

#### The Problem with /nix/store for Iterative Configs

The /nix/store approach works great for most things, but has a drawback:

**Every time you want to change a config file, you must:**
1. Edit the source file (`dotfiles/niri/config.kdl`)
2. Run `nixos-rebuild switch`
3. Wait for evaluation + rebuild
4. Test the change
5. Repeat

For configs you're actively tweaking (window manager keybinds, editor settings), this cycle is slow and annoying.

#### The Solution: Out-of-Store Symlinks

Instead of copying to `/nix/store`, you can symlink **directly** to your dotfiles:

```nix
# modules/niri/niri.nix
{ config, ... }:
{
  home-manager.users.${username} = { config, ... }: {
    # Instead of copying to /nix/store:
    xdg.configFile."niri/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/niri/config.kdl";
  };
}
```

#### What This Actually Does

**Normal approach:**
```
~/code/nixos-config/dotfiles/niri/config.kdl  (source)
                    ↓
            (copied to store)
                    ↓
      /nix/store/hash-config.kdl  (immutable copy)
                    ↓
              (symlinked)
                    ↓
       ~/.config/niri/config.kdl  (read-only symlink)
```

**With mkOutOfStoreSymlink:**
```
~/code/nixos-config/dotfiles/niri/config.kdl  (source)
                    ↓
          (symlinked directly)
                    ↓
       ~/.config/niri/config.kdl  (MUTABLE symlink)
```

#### Check It Yourself

```bash
ls -la ~/.config/niri/config.kdl

# Output:
lrwxrwxrwx  config.kdl -> /home/tom/code/nixos-config/dotfiles/niri/config.kdl
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                          NOT in /nix/store!
```

#### The Key Difference

**Normal (in-store):**
```bash
vim ~/.config/niri/config.kdl
# Error: can't save, file is read-only
```

**Out-of-store:**
```bash
vim ~/.config/niri/config.kdl
# Edits ~/code/nixos-config/dotfiles/niri/config.kdl directly
# Changes take effect IMMEDIATELY (no rebuild needed)
```

#### When to Use Each Approach

**Use /nix/store (normal) when:**
- Config is generated by Nix (`programs.fish.shellAliases`)
- Config rarely changes (`hardware-configuration.nix`)
- You want reproducibility guarantees
- Multiple machines share same config

**Use mkOutOfStoreSymlink when:**
- Config is hand-written (`niri/config.kdl`)
- You iterate frequently (keybinds, colors, layouts)
- You want instant feedback
- Config is specific to you, not generated

#### Examples in Your Config

You use `mkOutOfStoreSymlink` for:

```nix
# Niri window manager config (tweak keybinds often)
xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/code/nixos-config/dotfiles/niri/config.kdl";

# Firefox custom CSS (iterate on styling)
home.file.".mozilla/firefox/${username}/chrome".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/code/nixos-config/dotfiles/fennec/chrome";

# Doom Emacs config (constantly tweaking)
home.file.".config/doom".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/code/nixos-config/dotfiles/doom";
```

#### The Trade-offs

**Advantages:**
- Edit files directly, changes immediate
- No rebuild cycle for tweaks
- Faster iteration
- Still version controlled (in your repo)

**Disadvantages:**
- File is mutable (can break things)
- Not in /nix/store (no rollback to previous versions)
- Manual management (you're responsible for it)
- Less "pure" (not fully declarative)

#### Best Practice

Use both approaches together:

```nix
# Generated config → /nix/store
programs.fish.shellAliases = {
  rebuild = "sudo nixos-rebuild switch --flake ~/code/nixos-config/";
};

# Hand-written config → out-of-store symlink
xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/code/nixos-config/dotfiles/niri/config.kdl";
```

This gives you:
- Declarative, reproducible config (generated)
- Fast iteration (hand-written)
- Both version controlled
- Clear separation of concerns

### The Key Insight

**Traditional:**
- Config lives at `/etc` (mutable)
- Edit it directly
- Changes persist (until you break something)

**NixOS:**
- Config **source** lives in `.nix` files (version controlled)
- Config **output** lives in `/nix/store` (immutable)
- `/etc` just **points to** the store
- Changes are declarative and reproducible

## Configuration Complexity Levels

### Level 0: Single File (Beginner)

The simplest possible NixOS config:

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  # Boot
  boot.loader.systemd-boot.enable = true;

  # Networking
  networking.hostName = "mylaptop";
  networking.networkmanager.enable = true;

  # Users
  users.users.tom = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    vim
    git
    firefox
  ];

  # Services
  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
```

**Pros:**
- Simple
- Everything in one place
- Easy to understand

**Cons:**
- Gets messy fast (500+ lines)
- No organization
- Hard to enable/disable features
- Can't share between machines

### Level 1: Multiple Files with Commented Imports (Early Intermediate)

Split things into files, comment out what you don't need:

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./networking.nix
    ./users.nix
    ./packages.nix
    # ./desktop.nix       # Commented out - this is a server
    # ./gaming.nix        # Don't need gaming
    ./development.nix
  ];

  system.stateVersion = "25.05";
}
```

```nix
# /etc/nixos/desktop.nix
{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
  ];
}
```

**Pros:**
- Organized by topic
- Can toggle features by commenting imports
- Still relatively simple

**Cons:**
- Manual commenting is tedious
- Easy to forget what's enabled
- Still duplicates logic across machines
- No conditional logic

### Level 2: Imports with Manual Options (Intermediate)

Use NixOS's built-in options to control features:

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/desktop.nix
    ./modules/development.nix
  ];

  # Manually set what's enabled
  services.xserver.enable = true;                    # Enable desktop
  services.xserver.desktopManager.gnome.enable = false;  # No GNOME
  programs.hyprland.enable = true;                   # Use Hyprland instead

  virtualisation.docker.enable = true;               # Enable Docker
  programs.steam.enable = false;                     # No gaming

  system.stateVersion = "25.05";
}
```

```nix
# /etc/nixos/modules/desktop.nix
{ config, lib, pkgs, ... }:

{
  # This module sets things up if desktop is enabled
  # Uses built-in NixOS options like services.xserver.enable

  environment.systemPackages = lib.mkIf config.services.xserver.enable [
    pkgs.firefox
    pkgs.alacritty
  ];
}
```

**Pros:**
- No commenting/uncommenting
- Uses NixOS's native option system
- Cleaner than Level 1

**Cons:**
- Still setting options in main config
- Hard to see what's enabled at a glance
- No custom abstraction layer
- Mixing NixOS options with your preferences

### Level 3: Custom Module System with Enable Flags (Advanced)

Create your own option namespace with `myConfig.*`:

```nix
# hosts/whiterabbit/configuration.nix
{ lib, ... }:

{
  # Clean, organized, everything in one place
  myConfig.niri.enable = true;
  myConfig.kitty.enable = true;
  myConfig.fish.enable = true;
  myConfig.neovim.enable = true;
  myConfig.git.enable = true;
  myConfig.firefox.fennec.enable = true;
  myConfig.steam.enable = true;

  # Host-specific tweaks
  myConfig.users.username = "tom";
  myConfig.kanata.capsLockEscCtrl = true;  # Framework keyboard
}
```

```nix
# modules/neovim/default.nix
{ lib, ... }:

{
  imports = [ ./neovim.nix ];
}
```

```nix
# modules/neovim/neovim.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.neovim;
  username = config.myConfig.users.username;
in
{
  # Declare your own options
  options.myConfig.neovim = {
    enable = lib.mkEnableOption "Neovim text editor";
  };

  # Only apply if enabled
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.neovim ];

    home-manager.users.${username} = {
      programs.neovim = {
        enable = true;
        # ... your config
      };
    };
  };
}
```

**Pros:**
- **Clean host configs**: Just enable what you need
- **Custom abstraction**: `myConfig.*` is your domain
- **Discoverable**: All options in one namespace
- **Composable**: Modules don't know about each other
- **Shareable**: Easy to see what's enabled per-host

**Cons:**
- More boilerplate (default.nix + impl.nix for each module)
- Steeper learning curve
- Need to understand module system

### Level 4: Flakes + Multi-Host (Expert) ← **You Are Here**

Add flakes for reproducibility and easy multi-host management:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # Laptop
      whiterabbit = self.lib.mkSystem {
        hostname = "whiterabbit";
        hostConfig = ./hosts/whiterabbit/configuration.nix;
      };

      # Old laptop
      thinkpad-x1e = self.lib.mkSystem {
        hostname = "thinkpad-x1e";
        hostConfig = ./hosts/thinkpad-x1e/configuration.nix;
      };

      # Server
      server = self.lib.mkSystem {
        hostname = "production";
        hostConfig = ./hosts/server/configuration.nix;
      };
    };
  };
}
```

**Pros:**
- **Pinned dependencies**: Exact nixpkgs version locked
- **Multi-host**: Manage all machines from one repo
- **Portable**: `nix build .#whiterabbit` works anywhere
- **Reproducible**: Same flake.lock = identical builds

**Cons:**
- Flakes still considered "experimental"
- More complexity
- Longer rebuild times (evaluates whole flake)

### Level 5: Advanced Patterns (Expert++)

#### Shared Profiles

```nix
# profiles/workstation.nix
{ ... }:

{
  myConfig.niri.enable = true;
  myConfig.kitty.enable = true;
  myConfig.neovim.enable = true;
  myConfig.git.enable = true;
}
```

```nix
# hosts/laptop/configuration.nix
{ ... }:

{
  imports = [ ../../profiles/workstation.nix ];

  # Laptop-specific additions
  myConfig.framework.enable = true;
  myConfig.upower.enable = true;
}
```

#### Role-Based Configuration

```nix
# profiles/roles/developer.nix
{ ... }:

{
  myConfig.neovim.enable = true;
  myConfig.git.enable = true;
  myConfig.docker.enable = true;
  myConfig.vscode.enable = true;
}
```

```nix
# profiles/roles/gamer.nix
{ ... }:

{
  myConfig.steam.enable = true;
  myConfig.discord.enable = true;
  myConfig.obs.enable = true;
}
```

```nix
# hosts/gaming-rig/configuration.nix
{ ... }:

{
  imports = [
    ../../profiles/roles/developer.nix
    ../../profiles/roles/gamer.nix
  ];
}
```

#### Conditional Imports Based on Hardware

```nix
{ lib, ... }:

{
  imports =
    [ ./base.nix ]
    ++ lib.optional (builtins.pathExists /sys/class/power_supply) ./laptop.nix
    ++ lib.optional (builtins.pathExists /dev/nvidia0) ./nvidia.nix;
}
```

## Which Level Should You Use?

### Level 0-1: If you...
- Have one machine
- Are learning NixOS
- Don't need modularity
- Like simplicity over flexibility

### Level 2: If you...
- Have 1-2 machines
- Want organization
- Don't mind some duplication
- Comfortable with NixOS options

### Level 3: If you...
- Have 2+ machines
- Want clean host configs
- Like custom abstractions
- Willing to learn module system
- Want to share configs publicly

### Level 4: If you... ← **You chose this**
- Have 2+ machines (you have whiterabbit + thinkpad-x1e)
- Want reproducible builds (flake.lock pins dependencies)
- Manage configs in one repo (flakes)
- Need rollbacks and versioning
- Like declarative everything

### Level 5+: If you...
- Manage many machines (10+)
- Contribute to nixpkgs
- Work on a team
- Build shared NixOS infrastructure
- Want cutting-edge features

## Your Evolution

### Where You Started (Level 1-ish)
```nix
# configuration.nix
{
  imports = [
    ./fish.nix
    # ./zsh.nix  # Commented out
    ./neovim.nix
    # ./vim.nix  # Commented out
  ];
}
```

### Where You Are Now (Level 4)
```nix
# flake.nix - Multi-host management with locked dependencies
nixosConfigurations = {
  whiterabbit = self.lib.mkSystem {
    hostname = "whiterabbit";
    hostConfig = ./hosts/whiterabbit/configuration.nix;
    hardwareConfig = ./hardware-configuration.nix;
  };
  thinkpad-x1e = self.lib.mkSystem {
    hostname = "thinkpad-x1e";
    hostConfig = ./hosts/thinkpad-x1e/configuration.nix;
    hardwareConfig = ./hardware-configuration.nix;
  };
};

# hosts/whiterabbit/configuration.nix - Clean, modular enables
{
  myConfig.fish.enable = true;       # Fish enabled via module
  myConfig.neovim.enable = true;     # Neovim enabled via module
  myConfig.users.username = "tom";   # Custom option
}
```

### Why This is Better

**Before:**
- Comment/uncomment imports
- Hard to see what's active
- Duplication across hosts

**After:**
- Declarative enables
- Host config is self-documenting
- Modules are reusable
- Clean separation of concerns

## Common Gotchas

### "Why is my config so complex?"

Most example configs are Level 0-1. Yours is Level 4. That's intentional complexity for:
- Multi-host management (whiterabbit + thinkpad-x1e)
- Flakes (reproducible builds with locked dependencies)
- Custom module system (myConfig.* namespace)
- Modularity and shareability
- Learning advanced patterns

### "Can I mix levels?"

Yes! Common pattern:
- Level 4 for infrastructure (flakes, multi-host)
- Level 3 for your custom stuff (`myConfig.*`)
- Level 2 for NixOS built-ins (`services.nginx.enable`)
- Level 1 for quick hacks (comment out import)

### "Should I refactor everything to modules?"

No! Refactor when you feel pain:
- Adding a second machine? → Time for Level 3
- Configs getting messy? → Split into modules
- Still fits in one file? → Level 0 is fine

## Next Steps

You're at Level 4. To go deeper:

1. **Master the module system** (you're doing this now)
2. **Create shared profiles** (workstation.nix, server.nix, gamer.nix)
3. **Add assertions** (validate your config at build time)
4. **Use lib functions** (reduce duplication with helpers)
5. **Optimize flake evaluation** (lazy module imports, caching)
6. **Contribute back** (share your patterns, help others)

But honestly? **You're already doing advanced NixOS.** Most people never get past Level 1.

## Git + NixOS Workflow

### The Three Layers of Safety

NixOS gives you multiple independent rollback mechanisms:

1. **Git history** - Config source control (manual)
2. **NixOS generations** - Automatic system snapshots
3. **Btrfs snapshots** - Filesystem-level snapshots (optional)

### How Git Relates to nixos-rebuild

When you run `sudo nixos-rebuild switch`, NixOS reads from your **working directory** (not just committed changes):

- ✓ Uncommitted changes in `flake.nix` **will** be applied
- ✓ Uncommitted changes in modules **will** be applied
- ✗ Flake inputs are locked via `flake.lock` (only updates with `nix flake update`)
- ✓ Dotfiles are symlinked, so changes are always live (no rebuild needed)

### Best Practice: Commit After Every Successful Rebuild

```
Workflow:
1. Make changes to config
2. rebuild (test it works)
3. If successful: gita && gitc && gitp
4. NEVER commit broken configs
```

**Why this matters:**
- Each NixOS generation should have a corresponding git commit
- Git history lets you see "what changed when it broke"
- Without this discipline, you can boot into old generations but lose the source config that built them

### Git as a Safety Net

```bash
# Oops, bad config change - rollback in git
git log                    # Find last good commit
git checkout abc123        # Rollback to that commit
sudo nixos-rebuild switch  # Rebuild from old config
```

### NixOS Generations (Not Btrfs-Specific)

Every `nixos-rebuild switch` creates a new **generation** - a bootable snapshot of your system:

- Stored in `/nix/var/nix/profiles/system-*-link`
- Accessible from the bootloader menu at boot
- Rollback: `sudo nixos-rebuild switch --rollback`
- List: `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system`

### The Key Gotcha: Generations ≠ Git State

**IMPORTANT:** Booting into an old generation does NOT change your git state!

Example scenario:
1. You're at generation #50, git commit ABC
2. You make changes, rebuild → generation #51, git commit XYZ
3. Boot menu: select generation #50
4. Your system is running generation #50 (old config)
5. But `~/code/nixos-config` still shows commit XYZ (new source)
6. If you run `rebuild`, it builds from **current git state** (XYZ), not the old one

#### To Truly Match a Generation With Its Source

```bash
# 1. Boot into old generation (from bootloader)

# 2. Find what commit it was built from
git log --oneline

# 3. Checkout that commit to see/edit the original config
git checkout <commit-hash>

# 4. Rebuild if you want to modify and test
rebuild

# 5. Return to current state
git checkout main
```

### Btrfs Snapshots (Optional Enhancement)

If your system uses btrfs with automatic snapshots:

- Snapshots happen **before** each rebuild (via snapper, timeshift, or custom scripts)
- Provides **filesystem-level** rollback (includes `/home`, non-Nix state)
- Independent of NixOS generations
- Can recover deleted files, restore `/home` state

### Which to Use When

| Problem | Solution |
|---------|----------|
| Config broke | Git checkout + rebuild |
| System won't boot | Boot menu → select old generation |
| Deleted important files | Btrfs snapshot restore |
| Want to test old config | Git checkout → rebuild |
| Emergency recovery | Bootloader → old generation |

### The Key Difference: Source vs Built System

**Git checkout old code + rebuild:**
- Changes your source files
- System keeps running current generation until you rebuild
- Slow (must rebuild)
- Can modify before rebuilding

**Boot old generation:**
- System immediately runs old built config
- Source files unchanged
- Fast (no rebuild)
- Cannot modify (it's a frozen snapshot)

#### Mental Model

Think of it like:
- **Git** = recipe book
- **Generation** = pre-cooked frozen meal
- Booting old generation = eating old frozen meal (fast, but can't edit the recipe)
- Git checkout + rebuild = cooking from old recipe (slow, but can modify before cooking)

### The Key Insight

**Git tracks your intent (config source)**
**NixOS generations track built systems**
**Btrfs tracks filesystem state**

They're **complementary layers** - not the same thing!

This is why you should commit after every successful rebuild: to keep git history synchronized with generations.
