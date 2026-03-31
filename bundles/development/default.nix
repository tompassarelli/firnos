{ lib, ... }:
{
  options.myConfig.bundles.development = {
    enable = lib.mkEnableOption "core development workflow";
    git.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Git"; };
    gh.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GitHub CLI"; };
    delta.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable delta"; };
    vim.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Vim"; };
    claude.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Claude Code"; };
    direnv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable direnv"; };
    containers.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable containers"; };
    ripgrep.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ripgrep"; };
    fd.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable fd"; };
  };

  imports = [
    ./development.nix
  ];
}
