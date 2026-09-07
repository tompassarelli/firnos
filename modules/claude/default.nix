{ config, lib, pkgs, ... }:

((username: {
  options.myConfig.modules.claude-code.enable = lib.mkEnableOption "Claude Code fallback coding agent";
  config = lib.mkIf config.myConfig.modules.claude-code.enable {
    environment.systemPackages = [ pkgs.claude-code ];
    home-manager.users.${username} = ({ config, ... }: {
      home.file.".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/state/north/agents/current/instructions/shared/AGENTS.md";
    });
  };
}) config.myConfig.modules.users.username)
