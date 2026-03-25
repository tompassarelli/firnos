{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.tree.enable {
    environment.systemPackages = with pkgs; [ tree ];
  };
}
