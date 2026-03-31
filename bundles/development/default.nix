{ config, lib, ... }:
let cfg = config.myConfig.bundles.development;
in {
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

  config = lib.mkIf cfg.enable {
    myConfig.modules.git.enable = lib.mkDefault cfg.git.enable;
    myConfig.modules.gh.enable = lib.mkDefault cfg.gh.enable;
    myConfig.modules.delta.enable = lib.mkDefault cfg.delta.enable;
    myConfig.modules.vim.enable = lib.mkDefault cfg.vim.enable;
    myConfig.modules.claude.enable = lib.mkDefault cfg.claude.enable;
    myConfig.modules.direnv.enable = lib.mkDefault cfg.direnv.enable;
    myConfig.modules.containers.enable = lib.mkDefault cfg.containers.enable;
    myConfig.modules.ripgrep.enable = lib.mkDefault cfg.ripgrep.enable;
    myConfig.modules.fd.enable = lib.mkDefault cfg.fd.enable;
  };
}
