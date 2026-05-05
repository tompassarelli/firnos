{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.mako;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.mako.enable = lib.mkEnableOption "Mako notification daemon";
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      services.mako = {
        enable = true;
        settings = {
          default-timeout = 0;
          icons = 0;
          "app-name=kitty" = {
            default-timeout = 0;
          };
          "app-name=Spotify" = {
            invisible = 1;
          };
        };
      };
    };
  };
}
