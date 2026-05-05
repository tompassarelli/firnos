{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.claude;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.claude.enable = lib.mkEnableOption "Claude Code CLI configuration";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.master.claude-code ];
    home-manager.users.${username} = { config, ... }: {
      home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/claude/settings.json";
      home.file.".claude/commands".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/claude/commands";
    };
  };
}
