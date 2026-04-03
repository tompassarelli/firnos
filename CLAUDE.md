# NixOS Config

## Nix Flakes: New Files Must Be Git-Tracked

When adding a new file to this repo, always `git add` it before rebuilding. Nix flakes only see git-tracked files — untracked files are invisible to `builtins.readDir` and other flake evaluation, so the build will silently skip them.
