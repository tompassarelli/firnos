# FirnOS on macOS

FirnOS targets NixOS but supports macOS via [nix-darwin](https://github.com/LnL7/nix-darwin) — Apple's de facto NixOS-equivalent. You get the same authoring experience (write `.rkt`, `firn-build` regenerates `.nix`, validator catches typos before evaluation), the same `firn` CLI, and a curated subset of the modules in this repo that work on macOS.

## What works on macOS, what doesn't

**Works:**
- The full nisp DSL and validation toolchain (`nisp validate`, `nisp edit`, `nisp rename`, `nisp schema`, `nisp import`; `nisp-lsp` server).
- `firn` CLI commands (`host rebuild`, `module enable`/`disable`, `schema explain`, `repo doctor`, `repo upgrade`, `template …`, …) — `firn host rebuild` detects Darwin via `uname` and dispatches to `darwin-rebuild` instead of `nh os switch`.
- A safelist of cross-platform modules: shell tooling (`fish`, `direnv`, `zoxide`, `starship`, `atuin`), CLI utilities (`gh`, `delta`, `ripgrep`, `fd`, `vim`, `tree`, `btop`, `dust`, `eza`), git config — anything whose body only touches options nix-darwin also exposes (`programs.*`, `environment.systemPackages`, `home-manager.*`).

**Doesn't work** (skipped on darwin):
- NixOS-only modules whose `config-body` touches options nix-darwin doesn't declare: `boot/`, `niri/`, `kanata/`, `bluetooth/`, `networking/`, `containers/` (Podman), `system/` (sets a NixOS-string `stateVersion` incompatible with darwin's integer), most things under `services.*`.
- sops-nix (skipped in the darwin build for v1 — encrypted secrets need a separate pass).
- Stylix theming (its darwin support is incomplete).

The mechanism: `mkIf cfg.enable` defers a module's *value* but not its option *path*. `boot.kernel.sysctl` is rejected by nix-darwin even when wrapped in `mkIf` with `enable=false`. So FirnOS uses curated darwin compositions:

- **`bundles-darwin/`** — parallel to `bundles/`. Same `myConfig.bundles.<name>` namespace, so `(enable myConfig.bundles.terminal)` works on either platform and gets the right per-platform composition. Initial bundles: `terminal` (kitty default-on, ghostty dropped — nixpkgs build is Linux-only), `cli-tools`, `development` (NixOS bundle minus `containers`).
- **Module safelist in `flake.rkt`** — every module referenced by a `bundles-darwin/` bundle plus extras a darwin host might want directly.

## Discovering what works on darwin

Use `firn platform list` to answer "is this module/bundle compatible?" without trial-and-error builds:

```
$ firn platform list all         # full matrix
$ firn platform list darwin      # only darwin-compatible modules
$ firn platform list linux       # NixOS-only modules
$ firn platform show <name>      # single module/bundle, with reasons
$ firn platform list bundles     # bundle compat with blocking sub-modules
$ firn platform safelist         # printable safelist for flake.rkt
```

The check is *schema*-based: every option path the module sets must exist in the darwin options tree. Pre-req: both schemas extracted (`firn-extract-schema` for NixOS, `firn-extract-schema --darwin` for darwin). `firn repo doctor` warns when the darwin schema cache is stale.

**Limitation**: schema compatibility is necessary but not sufficient. A pure `(pkg X)` module sets only `environment.systemPackages` — that path exists on darwin, but the package itself may have no darwin build. Use `darwin-rebuild build --flake .#<host>` to confirm.

## Prerequisites

- macOS (Apple Silicon assumed; `flake.rkt` defaults the system tuple to `aarch64-darwin`)
- The Determinate or official Nix installer
- A macOS user account (the username goes in the host config; nix-darwin attaches home-manager to an existing macOS account, it doesn't create one)

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
firn host rebuild $(hostname)
```

`firn host rebuild` runs `firn-build → firn-validate → darwin-rebuild`. The validator step needs a darwin schema cache — see *Schema cache* below.

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

This populates `.nisp-cache/schema.json` against `darwinConfigurations.<host>.options`. Re-run after `firn repo upgrade now` (i.e. after `nix flake update`).

## Adding a module to the darwin safelist

If you want a module from `modules/` that isn't in the safelist:

1. Confirm it's darwin-compatible: `firn platform show <module-name>`. Look for `verdict: both`.
2. Open `flake.rkt`, find the `lib.mkDarwinSystem` block, and add the module name to the safelist.
3. Run `./scripts/firn-build && nix eval .#darwinConfigurations.$(hostname).config.system.build.toplevel.outPath`.
4. If it errors with `option 'X' does not exist`, the module touches NixOS-only options. Either rewrite the module to be platform-aware, or accept that it stays NixOS-only.

Generally safe candidates: any module whose `(config-body …)` only assigns to `programs.*`, `environment.systemPackages`, or `home-manager.*`. `firn platform list` does this check automatically by cross-referencing the darwin schema.

## Adding a bundle to `bundles-darwin/`

For an out-of-the-box composition rather than a single module:

1. `firn platform show <existing-bundle>` to see what blocks it on darwin (e.g. `bundles/development` is blocked by `containers`).
2. Create `bundles-darwin/<name>/default.rkt` mirroring the NixOS bundle minus the blocking sub-modules, plus any darwin-specific defaults (e.g. kitty default-on).
3. Append any net-new sub-modules to the safelist in `mkDarwinSystem`.
4. The bundle is auto-discovered on next `firn-build` — no flake edit needed.

## What you give up vs full FirnOS

- **No bundles.** Bundles reference NixOS-only modules; on darwin you enable individual modules instead. (You can still write your own darwin-only bundles with the `bundle-file` form, just don't reuse the existing ones.)
- **No sops-nix v1.** Encrypted secrets require additional plumbing for darwin; out of scope for the initial bootstrap. Use `~/.config/op-cli` or similar in the meantime.
- **No theming via stylix.** Stylix's darwin support is partial; v1 of `mkDarwinSystem` skips it.
- **System-level options narrower.** nix-darwin exposes `services.*` for a curated list (skhd, yabai, nix-daemon, etc.) — much smaller than NixOS's set. Check `man darwin-configuration` or run `firn schema explain services.X.enable` to see what's available.

## Verification

From a non-darwin machine you can still evaluate the structure:

```bash
nix eval .#darwinConfigurations.$(hostname).config.system.build.toplevel.outPath
```

The full build requires running on the actual Mac (the derivation references darwin tools).

## Troubleshooting

**`error: The option 'X' does not exist`** — the module references a NixOS-only option. Remove it from the safelist or gate it on `pkgs.stdenv.hostPlatform.isLinux`.

**`error: A definition for option 'home-manager.users.<u>.home.homeDirectory' is not of type 'absolute path'`** — your username option doesn't match an existing macOS user. Check `myConfig.modules.users.username` in your host config, and verify the user exists (`id $(whoami)`).

**`firn host rebuild` runs `nixos-rebuild` instead of `darwin-rebuild`** — `firn host rebuild` checks `uname -s`. If you're on macOS but the wrong path runs, file an issue with `uname -a` output.
