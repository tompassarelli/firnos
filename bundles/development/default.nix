{ lib, ... }:
{
  options.myConfig.development = {
    enable = lib.mkEnableOption "development tools and programming utilities";
    vim.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Vim"; };
    claude.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Claude Code"; };
    ripgrep.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ripgrep"; };
    fd.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable fd"; };
    unzip.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable unzip"; };
    parted.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable parted"; };
    wget.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable wget"; };
    curl.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable curl"; };
    imagemagick.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ImageMagick"; };
    ghostscript.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Ghostscript"; };
    nodejs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Node.js"; };
    python.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Python"; };
    uv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable uv"; };
    sqlite.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable SQLite"; };
    dbeaver.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable DBeaver"; };
    gh.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GitHub CLI"; };
    delta.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable delta"; };
  };

  imports = [
    ./development.nix
  ];
}
