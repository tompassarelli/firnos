{ lib, ... }:
{
  options.myConfig.modules.obsidian.enable = lib.mkEnableOption "Obsidian note-taking";
  imports = [ ./obsidian.nix ];
}
