{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.obsidian.enable = lib.mkEnableOption "Obsidian note-taking";

  config = lib.mkIf config.myConfig.modules.obsidian.enable {
    environment.systemPackages = [ pkgs.obsidian ];
  };
}
