{ config, lib, ... }:
let
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf config.myConfig.zoxide.enable {
    home-manager.users.${username} = {
      programs.fish.shellAliases.cd = "z";

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
