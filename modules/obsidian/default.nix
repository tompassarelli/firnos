{ lib, ... }:
{
  options.myConfig.obsidian.enable = lib.mkEnableOption "Obsidian note-taking";
  imports = [ ./obsidian.nix ];
}
