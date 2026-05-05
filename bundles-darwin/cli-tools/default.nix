{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.cli-tools;
in
{
  options.myConfig.bundles.cli-tools.enable = lib.mkEnableOption "modern CLI tools";
  options.myConfig.bundles.cli-tools.yazi.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable yazi";
  };
  options.myConfig.bundles.cli-tools.tree.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable tree";
  };
  options.myConfig.bundles.cli-tools.dust.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable dust";
  };
  options.myConfig.bundles.cli-tools.eza.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable eza";
  };
  options.myConfig.bundles.cli-tools.procs.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable procs";
  };
  options.myConfig.bundles.cli-tools.tealdeer.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable tealdeer";
  };
  options.myConfig.bundles.cli-tools.fastfetch.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable fastfetch";
  };
  options.myConfig.bundles.cli-tools.btop.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable btop";
  };
  options.myConfig.bundles.cli-tools.unrar.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable unrar";
  };
  options.myConfig.bundles.cli-tools.curl.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable curl";
  };
  options.myConfig.bundles.cli-tools.wget.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable wget";
  };
  options.myConfig.bundles.cli-tools.unzip.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable unzip";
  };
  options.myConfig.bundles.cli-tools.imagemagick.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable imagemagick";
  };
  options.myConfig.bundles.cli-tools.ghostscript.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable ghostscript";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.yazi.enable = lib.mkDefault cfg.yazi.enable;
    myConfig.modules.tree.enable = lib.mkDefault cfg.tree.enable;
    myConfig.modules.dust.enable = lib.mkDefault cfg.dust.enable;
    myConfig.modules.eza.enable = lib.mkDefault cfg.eza.enable;
    myConfig.modules.procs.enable = lib.mkDefault cfg.procs.enable;
    myConfig.modules.tealdeer.enable = lib.mkDefault cfg.tealdeer.enable;
    myConfig.modules.fastfetch.enable = lib.mkDefault cfg.fastfetch.enable;
    myConfig.modules.btop.enable = lib.mkDefault cfg.btop.enable;
    myConfig.modules.unrar.enable = lib.mkDefault cfg.unrar.enable;
    myConfig.modules.curl.enable = lib.mkDefault cfg.curl.enable;
    myConfig.modules.wget.enable = lib.mkDefault cfg.wget.enable;
    myConfig.modules.unzip.enable = lib.mkDefault cfg.unzip.enable;
    myConfig.modules.imagemagick.enable = lib.mkDefault cfg.imagemagick.enable;
    myConfig.modules.ghostscript.enable = lib.mkDefault cfg.ghostscript.enable;
  };
}
