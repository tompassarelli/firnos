{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.tree;
in
{
  options.myConfig.modules.tree.enable = lib.mkEnableOption "Enable tree file tree display utility";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ tree ];
  };
}
