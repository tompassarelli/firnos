{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.development;
in
{
  options.myConfig.bundles.development.enable = lib.mkEnableOption "core development workflow";
  options.myConfig.bundles.development.git.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable git";
  };
  options.myConfig.bundles.development.gh.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable gh";
  };
  options.myConfig.bundles.development.delta.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable delta";
  };
  options.myConfig.bundles.development.vim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable vim";
  };
  options.myConfig.bundles.development.claude.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable claude";
  };
  options.myConfig.bundles.development.direnv.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable direnv";
  };
  options.myConfig.bundles.development.ripgrep.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable ripgrep";
  };
  options.myConfig.bundles.development.fd.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable fd";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.git.enable = lib.mkDefault cfg.git.enable;
    myConfig.modules.gh.enable = lib.mkDefault cfg.gh.enable;
    myConfig.modules.delta.enable = lib.mkDefault cfg.delta.enable;
    myConfig.modules.vim.enable = lib.mkDefault cfg.vim.enable;
    myConfig.modules.claude.enable = lib.mkDefault cfg.claude.enable;
    myConfig.modules.direnv.enable = lib.mkDefault cfg.direnv.enable;
    myConfig.modules.ripgrep.enable = lib.mkDefault cfg.ripgrep.enable;
    myConfig.modules.fd.enable = lib.mkDefault cfg.fd.enable;
  };
}
