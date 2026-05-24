{ config, lib, pkgs, ... }:

let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.zoxide.enable = lib.mkEnableOption "zoxide smart directory jumper";
  config = lib.mkIf config.myConfig.modules.zoxide.enable {
    home-manager.users.${username} = {
      programs.bash.shellAliases.cd = "z";
      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
