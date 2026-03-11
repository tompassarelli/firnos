{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.kitty;
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf cfg.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============
    # (None needed - kitty is installed via home-manager)

    # ============ HOME-MANAGER CONFIGURATION ============

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
