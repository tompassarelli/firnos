{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.obsidian.enable {
    environment.systemPackages = [ pkgs.obsidian ];
  };
}
