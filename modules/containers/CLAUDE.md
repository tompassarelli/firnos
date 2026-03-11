You are running inside a Nix dev sandbox container.

## Installing packages

Do NOT use apt, dnf, pip install --global, or any imperative package manager.

To install a package:
1. Edit /home/dev/flake.nix
2. Add the package to devShells.default.packages
3. Run: nix develop /home/dev --command bash

Search for package names with: nix search nixpkgs <query>

## Environment

- Working directory: /work (mounted from host)
- Nix flake for dev packages: /home/dev/flake.nix
- All package changes are declarative and version-controlled
