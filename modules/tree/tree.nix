{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.tree.enable {
    environment.systemPackages = with pkgs; [ tree ];
  };
}
