{ config, lib, ... }:
let cfg = config.myConfig.bundles.cli-tools;
in {
  options.myConfig.bundles.cli-tools = {
    enable = lib.mkEnableOption "modern CLI tools";
    yazi.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable yazi"; };
    tree.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable tree"; };
    dust.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable dust"; };
    eza.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable eza"; };
    procs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable procs"; };
    tealdeer.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable tealdeer"; };
    fastfetch.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable fastfetch"; };
    btop.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable btop"; };
    unrar.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable unrar"; };
    curl.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable curl"; };
    wget.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable wget"; };
    unzip.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable unzip"; };
    imagemagick.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ImageMagick"; };
    ghostscript.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Ghostscript"; };
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
