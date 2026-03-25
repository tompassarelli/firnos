{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.tree = {
    enable = lib.mkEnableOption "Enable tree file tree display utility";
  };

  config = lib.mkIf config.myConfig.modules.tree.enable {
    environment.systemPackages = with pkgs; [ tree ];
  };
}
