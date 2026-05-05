{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.kitty;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.kitty.enable = lib.mkEnableOption "Kitty terminal configuration";
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.kitty = {
        enable = true;
        settings = {
          tab_bar_edge = "top";
          tab_bar_style = "powerline";
          window_padding_width = "2 0 0 3";
        };
      };
    };
  };
}
