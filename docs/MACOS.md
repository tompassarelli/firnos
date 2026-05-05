# FirnOS on macOS

FirnOS targets NixOS but supports macOS via [nix-darwin](https://github.com/LnL7/nix-darwin) — Apple's de facto NixOS-equivalent. You get the same authoring experience (write `.rkt`, `firn-build` regenerates `.nix`, validator catches typos before evaluation), the same `firn` CLI, and a curated subset of the modules in this repo that work on macOS.

## What works on macOS, what doesn't

**Works:**
- The full nisp DSL and validation toolchain (`nisp-validate`, `nisp-edit`, `nisp-rename`, `nisp-schema`, `nisp-import`, `nisp-lsp`).
- `firn` CLI commands (`rebuild`, `enable`/`disable`, `explain`, `doctor`, `upgrade`, `scaffold`, …) — `firn rebuild` detects Darwin via `uname` and dispatches to `darwin-rebuild` instead of `nh os switch`.
- A safelist of cross-platform modules: shell tooling (`fish`, `direnv`, `zoxide`, `starship`, `atuin`), CLI utilities (`gh`, `delta`, `ripgrep`, `fd`, `vim`, `tree`, `btop`, `dust`, `eza`), git config — anything whose body only touches options nix-darwin also exposes (`programs.*`, `environment.systemPackages`, `home-manager.*`).

**Doesn't work** (skipped on Darwin):
- NixOS-only modules: `boot/`, `niri/`, `kanata/`, `bluetooth/`, `networking/`, `containers/` (Podman), `system/` (sets a NixOS-string `stateVersion` incompatible with darwin's integer), anything in `services.*` that nix-darwin doesn't expose.
- The full bundle layer (most bundles pull in NixOS-only modules).
- sops-nix (skipped in the darwin build for v1 — encrypted secrets need a separate pass).
- Stylix theming (its darwin support is incomplete).

The mechanism: `mkIf` defers a module's *value* but not its option *path*. `boot.kernel.sysctl` is invalid on darwin even when wrapped in `mkIf cfg.enable` with `enable=false`. So FirnOS maintains a hand-curated safelist of darwin-importable modules in `flake.rkt`'s `lib.mkDarwinSystem` rather than auto-discovering everything.

## Prerequisites

- macOS (Apple Silicon assumed; `flake.rkt` defaults the system tuple to `aarch64-darwin`)
- The Determinate or official Nix installer
- A friend's user account on the Mac (the username goes in the host config)

## Bootstrap

### 1. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Determinate's installer enables flakes by default and is reversible (`/nix/nix-installer uninstall`). Restart your terminal so `nix` is on `$PATH`.

### 2. Install nix-darwin

```bash
nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake github:LnL7/nix-darwin/nix-darwin-25.11#simple
```

This bootstraps a minimal nix-darwin install. Skip if you've already done it.

### 3. Clone the repos

```bash
mkdir -p ~/code && cd ~/code
git clone https://github.com/tompassarelli/firnos
git clone https://github.com/tompassarelli/nisp        # sibling clone — firn-build expects ../nisp
cd firnos
```

Set `NISP_PATH=/path/to/nisp` in your environment if you cloned them elsewhere.

### 4. Configure your host

`hosts/ashashi/configuration.rkt` is the running example. To create your own host:

```bash
cp -r hosts/ashashi hosts/$(hostname)
$EDITOR hosts/$(hostname)/configuration.rkt   # adjust the username and module list
```

Then add a `darwinConfigurations` entry to `flake.rkt`:

```racket
(darwinConfigurations
  (att
    (ashashi
      (call self.lib.mkDarwinSystem
        (att
          (hostname "ashashi")
          (hostConfig (p "./hosts/ashashi/configuration.nix")))))
    ;; add your own:
    (your-host
      (call self.lib.mkDarwinSystem
        (att
          (hostname "your-host")
          (hostConfig (p "./hosts/your-host/configuration.nix")))))))
```

Regenerate the flake and git-add:

```bash
./scripts/firn-build
git add hosts/your-host flake.nix flake.rkt
```

### 5. First rebuild

```bash
sudo darwin-rebuild switch --flake .#$(hostname)
```

Or, once `firn` is on `$PATH`:

```bash
firn rebuild $(hostname)
```

`firn rebuild` runs `firn-build → firn-validate → darwin-rebuild`. The validator step needs a darwin schema cache — see *Schema cache* below.

### 6. Optional: install the `firn` CLI

```bash
./scripts/firn-build-bin   # installs ~/.local/bin/firn
```

Add `~/.local/bin` to your `$PATH`. Requires Racket on the system; the cross-platform safelist enables `bundles/racket` only on hosts that need it. For the minimal ashashi setup we install Racket via `brew install racket-minimal` or `nix-env -iA nixpkgs.racket-minimal` instead.

## Schema cache

The validator needs a schema extracted from the *darwin* options tree:

```bash
./scripts/firn-extract-schema --darwin $(hostname)
```

This populates `.nisp-cache/schema.json` against `darwinConfigurations.<host>.options`. Re-run after `firn upgrade` (i.e. after `nix flake update`).

## Adding a module to the darwin safelist

If you want a module from `modules/` that isn't in the safelist:

1. Open `flake.rkt`, find the `lib.mkDarwinSystem` block, and add the module name to the `(lst ...)` list of safe imports.
2. Run `./scripts/firn-build && nix eval .#darwinConfigurations.$(hostname).config.system.build.toplevel.outPath`.
3. If it errors with `option 'X' does not exist`, the module touches NixOS-only options. Either rewrite the module to be platform-aware, or accept that it stays NixOS-only.

Generally safe candidates: any module under `modules/` whose `(config-body …)` only assigns to `programs.*`, `environment.systemPackages`, or `home-manager.*`. Run `head modules/<name>/default.rkt` to peek.

## What you give up vs full FirnOS

- **No bundles.** Bundles reference NixOS-only modules; on darwin you enable individual modules instead. (You can still write your own darwin-only bundles with the `bundle-file` form, just don't reuse the existing ones.)
- **No sops-nix v1.** Encrypted secrets require additional plumbing for darwin; out of scope for the initial bootstrap. Use `~/.config/op-cli` or similar in the meantime.
- **No theming via stylix.** Stylix's darwin support is partial; v1 of `mkDarwinSystem` skips it.
- **System-level options narrower.** nix-darwin exposes `services.*` for a curated list (skhd, yabai, nix-daemon, etc.) — much smaller than NixOS's set. Check `man darwin-configuration` or run `firn explain services.X.enable` to see what's available.

## Verification

From a non-darwin machine you can still evaluate the structure:

```bash
nix eval .#darwinConfigurations.$(hostname).config.system.build.toplevel.outPath
```

The full build requires running on the actual Mac (the derivation references darwin tools).

## Troubleshooting

**`error: The option 'X' does not exist`** — the module references a NixOS-only option. Remove it from the safelist or gate it on `pkgs.stdenv.hostPlatform.isLinux`.

**`error: A definition for option 'home-manager.users.<u>.home.homeDirectory' is not of type 'absolute path'`** — your username option doesn't match an existing macOS user. Check `myConfig.modules.users.username` in your host config, and verify the user exists (`id $(whoami)`).

**`firn rebuild` runs `nixos-rebuild` instead of `darwin-rebuild`** — `firn rebuild` checks `uname -s`. If you're on macOS but the wrong path runs, file an issue with `uname -a` output.
