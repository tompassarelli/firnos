{ config, lib, ... }:
let
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf config.myConfig.claude.enable {
    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = { config, ... }: {
      # Claude settings.json
      home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/claude/settings.json";

      # Claude custom commands directory (global commands)
      home.file.".claude/commands".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/claude/commands";
    };
  };
}
