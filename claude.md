NEVER put plaintext passwords, secrets, API keys, or credentials anywhere in this repo.
All secrets must go through sops-nix as encrypted files in secrets/.
If you need a secret value in a module, use sops.secrets."name" — never inline it.

WHEN: adding a module
see modules/bluetooth/ for the standard pattern: default.nix (option declaration) + <name>.nix (implementation)
see bundles/auth/ for the bundle pattern: enables multiple modules under one toggle

assume new modules only get added to whiterabbit machine host

after module changes, verify with:
  nix build .#nixosConfigurations.whiterabbit.config.system.build.toplevel --dry-run
  nix build .#nixosConfigurations.thinkpad-x1e.config.system.build.toplevel --dry-run

new files must be git-added before nix can see them (flake uses git tree)
