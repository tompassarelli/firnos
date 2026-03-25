## Security

NEVER put plaintext passwords, secrets, API keys, or credentials anywhere in this repo.
All secrets must go through sops-nix as encrypted files in secrets/.
If you need a secret value in a module, use sops.secrets."name" — never inline it.

NEVER chain `git commit && git push` in one command. Always:
1. `git commit` first
2. Verify the pre-commit hook passed (gitleaks secret detection)
3. If secrets are detected, fix the leak before proceeding
4. Only then advise the user to push

## Architecture

Two namespaces: `myConfig.modules.*` (atoms) and `myConfig.bundles.*` (molecules).

### Module pattern (1 package or 1 service, no exceptions)

```
modules/<name>/default.nix   — option declaration
modules/<name>/<name>.nix    — implementation behind mkIf
```

```nix
# default.nix
{ lib, ... }:
{
  options.myConfig.modules.<name>.enable = lib.mkEnableOption "<description>";
  imports = [ ./<name>.nix ];
}

# <name>.nix
{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.<name>.enable {
    environment.systemPackages = [ pkgs.<package> ];
  };
}
```

### Bundle pattern (pure composition, never installs packages)

```
bundles/<name>/default.nix   — option declarations with per-module toggles
bundles/<name>/<name>.nix    — config propagation via mkDefault
```

```nix
# default.nix
{ lib, ... }:
{
  options.myConfig.bundles.<name> = {
    enable = lib.mkEnableOption "<description>";
    foo.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable foo"; };
    bar.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable bar"; };
  };
  imports = [ ./<name>.nix ];
}

# <name>.nix
{ config, lib, ... }:
let
  cfg = config.myConfig.bundles.<name>;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.foo.enable = lib.mkDefault cfg.foo.enable;
    myConfig.modules.bar.enable = lib.mkDefault cfg.bar.enable;
  };
}
```

### Proxying module sub-options through bundles

When a module has options beyond just `enable` (e.g. firefox has fennec.enable, stylix has chosenTheme), the bundle must proxy those so users don't reach past the bundle:

```nix
# In bundle default.nix:
firefox.fennec.enable = lib.mkOption { type = lib.types.bool; default = false; description = "..."; };

# In bundle <name>.nix:
myConfig.modules.firefox.fennec.enable = lib.mkDefault cfg.firefox.fennec.enable;
```

### Bundle-to-bundle composition

Bundles can compose other bundles (e.g. development includes python):

```nix
# In bundle default.nix:
python.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable python bundle"; };

# In bundle <name>.nix:
myConfig.bundles.python.enable = lib.mkDefault cfg.python.enable;
```

## Rules

- 1 package = 1 module. No exceptions. Inseparable pairs do not exist.
- Bundles never install packages. They only enable modules via mkDefault.
- Auto-import: just create the directory and git-add. No flake.nix edits.
- Assume new modules only get added to whiterabbit host.
- New files must be git-added before nix can see them (flake uses git tree).

## Fish Functions

Fish functions live in `dotfiles/fish/functions/` as individual `.fish` files, symlinked via out-of-store symlinks. `modules/fish/fish.nix` auto-discovers them.

`firn` is the CLI for managing this NixOS config (modules, bundles, secrets, rebuilds). Run `firn` with no args to see all commands. It should only contain subcommands that operate on the nixos-config repo itself — general-purpose tools like `sandbox`, `vpn`, `gif` etc. stay as standalone fish functions.

## Verification

```
nix build .#nixosConfigurations.whiterabbit.config.system.build.toplevel
```

Only verify whiterabbit. Skip thinkpad-x1e.
