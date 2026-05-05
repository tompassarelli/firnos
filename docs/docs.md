# Getting Started with FirnOS

## The /nix/store: Why NixOS Is Different

On traditional Linux, you edit config files directly. On NixOS, config files are **read-only symlinks** to `/nix/store`:

```bash
ls -la /etc/nginx/nginx.conf
# lrwxrwxrwx  /etc/nginx/nginx.conf -> /nix/store/abc123-nginx.conf
```

The `/nix/store` is immutable and content-addressed — every path includes a hash of its inputs. You write `.nix` files, Nix evaluates them into store paths, and the system symlinks to those paths. This makes your system declarative, reproducible, atomic, and rollbackable.

In FirnOS the *write interface* is one step removed: you author `.rkt` (nisp), `firn-build` regenerates `.nix`, and from there it's the standard Nix flow:

```
You write:       ~/code/firnos/**/*.rkt
                           ↓  (firn-build regenerates)
Generated Nix:   ~/code/firnos/**/*.nix
                           ↓  (nix evaluates)
Nix generates:   /nix/store/hash-config
                           ↓  (creates symlink)
System uses:     /etc/thing -> /nix/store/hash-config
```

Both `.rkt` and `.nix` are committed because the flake reads from the git tree.

## The Abstraction Spectrum

There's a spectrum of how people organize NixOS configs. Each level solves a real problem but introduces new ones:

**Single file** — everything in one `configuration.nix`. Simple, but becomes a mess at 500+ lines. No way to share config between machines.

**Split files with imports** — organized by topic, comment out what you don't need. Better, but commenting/uncommenting is tedious and error-prone.

**Custom modules with enable flags** — declare a `myConfig.*` namespace with `mkEnableOption`. Host configs become a clean list of enables. Composable and shareable, but more boilerplate per module.

**Flakes** — pin dependencies with a lockfile, manage multiple hosts from one repo. Reproducible builds across machines. More complexity upfront but pays off immediately with multi-host setups.

Each level builds on the previous. You can mix them — flakes for infrastructure, custom modules for your features, raw NixOS options where they make sense.

## What FirnOS Chose

FirnOS sits at the top of that spectrum with two namespaces:

**`myConfig.modules.*`** = atoms. One package or service each. Each lives in `modules/<name>/default.rkt` (with a regenerated `default.nix` sibling).

Most modules are a single file. The simplest install-package case is one line:

```racket
;; modules/awscli/default.rkt
#lang nisp
(pkg awscli2 "AWS CLI v2")
```

`(pkg name desc)` expands to the standard `module-file` boilerplate — the `mkEnableOption`, the `mkIf cfg.enable`, the `environment.systemPackages` setter — so authors don't repeat themselves. For services, `(svc openssh)` is the analogous shortcut.

When a module has complex options (multiple `mkOption` declarations beyond `enable`), use the explicit form:

```racket
;; modules/foo/default.rkt
#lang nisp
(module-file modules foo
  (desc "foo configuration")
  (option-attrs
    (port (mkopt #:type lib.types.port
                 #:default 8080
                 #:desc "Listen port")))
  (config-body
    (set services.foo.enable #t)
    (set services.foo.port cfg.port)))
```

When a module spans many lines, split into `default.rkt` (options) and `<name>.rkt` (implementation). Currently `chrome`, `firefox`, `glide`, `kanata`, `nyxt`, `stylix`, `system`, and `users` use this split.

**`myConfig.bundles.*`** = molecules. Pure composition — groups modules under one toggle. Never installs packages directly. Each module in a bundle can be individually disabled at the host:

```racket
;; in hosts/<your-host>/configuration.rkt
(enable myConfig.bundles.media)
(set myConfig.modules.lutris.enable #f)   ; opt out of one bundle member
```

This works through NixOS priorities: bundles propagate enables with `mkDefault` (priority 1000), so a direct `false` (priority 100) always wins.

**Auto-import**: the flake discovers all modules and bundles from directory listings. Adding a new module = create the directory + `.rkt`, run `firn-build`, `git add` both files. No flake edits.

See [`template/`](../template/) for a complete starting config to copy.

## Adding a New Host

1. Create `hosts/new-hostname/configuration.rkt`:
   ```racket
   #lang nisp
   (host-file
     (set myConfig.modules.system.stateVersion "25.11")
     (set myConfig.modules.users.username "yourname")
     (enable myConfig.modules.users
             myConfig.modules.boot
             myConfig.modules.networking
             myConfig.bundles.racket           ; required for the firn-build pipeline
             myConfig.bundles.development))
   ```

2. Add a `nixosConfigurations` entry in `flake.rkt` (regenerates into `flake.nix`):
   ```racket
   (new-hostname
     (call self.lib.mkSystem
       (att
         (hostname "new-hostname")
         (hostConfig (p "./hosts/new-hostname/configuration.nix"))
         (hardwareConfig (p "./hardware-configuration.nix")))))
   ```

3. `firn-build && git add hosts/new-hostname flake.nix` — the flake's dynamic auto-discovery picks up the rest. Modules and bundles are auto-imported; only the host entry needs adding.

For a macOS machine, see [`MACOS.md`](MACOS.md) — uses `lib.mkDarwinSystem` and a parallel `darwinConfigurations` entry.

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

## Secrets Management

NixOS configs end up in the world-readable `/nix/store`, so you can't put passwords or API keys in `.nix` files directly. FirnOS uses [sops-nix](https://github.com/Mic92/sops-nix) to encrypt secrets at rest in the repo and decrypt them at system activation.

### How it works

```
You write:       secrets/aws.yaml (plaintext via sops CLI)
                           ↓  (sops encrypts with your age key)
Repo stores:     secrets/aws.yaml (encrypted ciphertext)
                           ↓  (sops-nix decrypts at activation)
System uses:     /run/secrets/aws-access-key-id (plaintext, owner-only)
```

Encryption uses [age](https://age-encryption.org/). Your age private key lives at **`/var/lib/sops-nix/key.txt`** (owned by you, mode 400) and is **not** in the repo. The authoritative backup is in Bitwarden; if you ever lose the file, restore it from there.

Why `/var/lib/sops-nix/key.txt` and not `~/.config/sops/age/keys.txt` (sops's usual default)? Because sops-nix runs at stage-2-init, *before* `/home` is mounted. If the key lived under `/home`, activation would fail with `cannot read keyfile` and `/run/secrets/` would never be populated — silently breaking anything that reads from it.

To keep the interactive `sops` CLI pointed at the same file, `flake.nix` sets `environment.sessionVariables.SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt"`. One file, one path, one thing to rotate.

**Rotating the key**: overwrite `/var/lib/sops-nix/key.txt` and update Bitwarden. That's it.

### Setup (already done in FirnOS)

The flake handles the plumbing:
- `sops-nix` is a flake input and its NixOS module is imported
- `sops.age.keyFile = "/var/lib/sops-nix/key.txt"` so activation works before `/home` is mounted
- `SOPS_AGE_KEY_FILE` env var points the CLI at the same path
- `sops` and `age` CLI tools are in `environment.systemPackages`
- `.sops.yaml` at the repo root defines which age key encrypts which paths

### Creating an encrypted secrets file

```bash
sops secrets/my-service.yaml
```

This opens your `$EDITOR` with a plaintext YAML file. Add your secrets as key-value pairs:

```yaml
api-key: sk-abc123...
api-secret: def456...
```

Save and close — sops encrypts the file automatically. The `.sops.yaml` creation rule matches `secrets/*.yaml`:

```yaml
creation_rules:
  - path_regex: secrets/[^/]+\.(yaml|json|env|ini)$
    key_groups:
      - age:
        - *admin
```

To edit an existing encrypted file later: `sops secrets/my-service.yaml` (same command).

### Declaring secrets in a module

In your module's `.nix` file, declare each secret with `sops.secrets`:

```nix
{ config, lib, pkgs, flakeRoot, ... }:
let
  cfg = config.myConfig.modules.my-service;
  username = config.myConfig.modules.users.username;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets."api-key" = {
      sopsFile = flakeRoot + "/secrets/my-service.yaml";
      owner = username;
    };
    sops.secrets."api-secret" = {
      sopsFile = flakeRoot + "/secrets/my-service.yaml";
      owner = username;
    };

    environment.systemPackages = [ pkgs.my-service ];
  };
}
```

At activation, sops-nix decrypts each secret to `/run/secrets/<key-name>`, owned by the specified user and readable only by them.

### Using decrypted secrets

Secrets land at `/run/secrets/<key-name>` as plain files. Common patterns:

**Environment variables** (e.g. in fish config or shell init):
```bash
set -x API_KEY (cat /run/secrets/api-key)
```

**Service config** — point `ExecStartPre` or a wrapper script at the secret file:
```nix
systemd.services.my-service.serviceConfig.EnvironmentFile = "/run/secrets/my-service-env";
```

**Direct file read** — any program that accepts a path to a credentials file can point at `/run/secrets/...`.

### Checklist for adding a new secret

1. Create or edit the encrypted file: `sops secrets/<name>.yaml`
2. Add `sops.secrets."<key>"` declarations in your module's `.nix` file
3. Wire the decrypted paths into your service/environment
4. `git add secrets/<name>.yaml` (the encrypted file — never commit plaintext)
5. Build: `nix build .#nixosConfigurations.whiterabbit.config.system.build.toplevel`

## Sandboxed Dev Containers

FirnOS includes a container system for running Claude Code in isolated environments. The idea: give Claude full tool access inside a throwaway container where it can't damage your host system.

### How it works

```
claude-sandbox.nix          Nix builds an OCI container image
        ↓                   (bash, git, node, python, nix, claude-code)
sandbox <name>              Creates a podman container from that image
        ↓                   Mounts your project into /work
        ↓                   Copies your Claude credentials in
        ↓                   Drops you into a bash shell
claude                      Run Claude Code inside the container
```

The container has everything Claude needs to work autonomously — git, gh, node, python, ripgrep, fd, curl, jq, and even nix itself (so Claude can install additional packages). Your project files are mounted read-write at `/work`, but nothing else on your host is accessible.

### First-time setup

```bash
sandbox --rebuild
```

This runs `nix build .#claude-sandbox`, producing an OCI image tarball, then loads it into podman. The build output is a `result` symlink in the repo root (gitignored) pointing to the image in `/nix/store`. A stable copy is kept at `builds/claude-sandbox` so future rebuilds don't depend on `result`.

### Creating a sandbox

```bash
# Sandbox the current directory
cd ~/code/my-project
sandbox myproject

# Sandbox specific directories (mounted as /work/<dirname>)
sandbox myproject ~/code/frontend ~/code/backend
```

On first create, `sandbox`:
1. Builds the container image if it doesn't exist yet
2. Copies your `~/.claude` credentials into a per-sandbox data directory (`~/.local/share/makedev/<name>/`)
3. Pre-trusts `/work` so Claude skips the trust dialog
4. Backs up your project files (disable with `--no-backup`)
5. Creates the podman container with your project mounted at `/work`
6. Drops you into bash inside the container

### Re-entering a sandbox

```bash
sandbox myproject
```

If the container already exists, it just starts it and attaches — no rebuild, no re-copy. Your previous state (installed packages, file changes) is preserved.

### Inside the container

```bash
claude          # Start Claude Code — it sees /work and can edit freely
```

Claude has full autonomy inside the container. It can:
- Edit any file in `/work` (your mounted project)
- Run tests, build, lint
- Use git and gh to commit, push, create PRs
- Install packages with nix (`nix profile install nixpkgs#whatever`)

Changes to `/work` are real — they're your actual project files via the mount. Everything else (installed packages, temp files) lives only in the container.

### Managing sandboxes

```bash
sandbox --list              # List all sandboxes and their status
sandbox --rm myproject      # Delete a sandbox and its data
sandbox --rebuild           # Rebuild the base image (after changing claude-sandbox.nix)
```

### The `result` symlink

You'll see a `result` symlink in the repo root. This is a standard nix artifact — every `nix build` creates one pointing to the build output in `/nix/store`. It gets overwritten by whatever you build next (system build, container image, etc.). It's in `.gitignore` and can be safely deleted at any time.

### Customizing the container image

Edit `modules/containers/claude-sandbox.nix` to add packages to the image. The container also includes a starter `flake.nix` at `~/flake.nix` inside the container, so Claude can declaratively add packages without rebuilding the base image.

After editing, run `sandbox --rebuild` to pick up changes.
