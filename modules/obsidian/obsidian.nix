{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.obsidian.enable {
    environment.systemPackages = [ pkgs.obsidian ];
  };
}
