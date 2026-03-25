{ config, lib, ... }:

let
  cfg = config.myConfig.cli-tools;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.yazi.enable = lib.mkDefault cfg.yazi.enable;
    myConfig.tree.enable = lib.mkDefault cfg.tree.enable;
    myConfig.dust.enable = lib.mkDefault cfg.dust.enable;
    myConfig.eza.enable = lib.mkDefault cfg.eza.enable;
    myConfig.procs.enable = lib.mkDefault cfg.procs.enable;
    myConfig.tealdeer.enable = lib.mkDefault cfg.tealdeer.enable;
    myConfig.fastfetch.enable = lib.mkDefault cfg.fastfetch.enable;
    myConfig.btop.enable = lib.mkDefault cfg.btop.enable;
  };
}
