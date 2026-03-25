{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.cli-tools;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.yazi.enable = lib.mkDefault cfg.yazi.enable;
    myConfig.modules.tree.enable = lib.mkDefault cfg.tree.enable;
    myConfig.modules.dust.enable = lib.mkDefault cfg.dust.enable;
    myConfig.modules.eza.enable = lib.mkDefault cfg.eza.enable;
    myConfig.modules.procs.enable = lib.mkDefault cfg.procs.enable;
    myConfig.modules.tealdeer.enable = lib.mkDefault cfg.tealdeer.enable;
    myConfig.modules.fastfetch.enable = lib.mkDefault cfg.fastfetch.enable;
    myConfig.modules.btop.enable = lib.mkDefault cfg.btop.enable;
  };
}
