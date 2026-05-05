{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.atuin;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.atuin.enable = lib.mkEnableOption "atuin shell history sync";
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = { config, ... }: {
      programs.atuin = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          auto_sync = true;
          sync_frequency = "5m";
          search_mode = "fuzzy";
        };
      };
    };
  };
}
