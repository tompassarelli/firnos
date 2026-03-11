{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.direnv;
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;  # better caching for nix flakes
    };

    # Add shell integration via home-manager
    home-manager.users.${username} = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
  };
}
