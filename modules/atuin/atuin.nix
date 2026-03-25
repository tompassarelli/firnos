{ config, lib, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  config = lib.mkIf config.myConfig.modules.atuin.enable {
    home-manager.users.${username} = {
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
