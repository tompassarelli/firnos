{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.zoxide;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.zoxide.enable = lib.mkEnableOption "zoxide smart directory jumper";
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.fish.shellAliases.cd = "z";
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
