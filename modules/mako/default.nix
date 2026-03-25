{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.mako;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.mako = {
    enable = lib.mkEnableOption "Mako notification daemon";
  };

  config = lib.mkIf cfg.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============
    # (None needed - mako is installed via home-manager)

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = {
      services.mako = {
        enable = true;
        settings = {
          default-timeout = 0; # Don't auto-dismiss notifications
          icons = 0; # Hide app icons

          # Claude Code notifications - no auto-dismiss
          "app-name=kitty" = {
            default-timeout = 0;
          };

          # Suppress Spotify track change notifications
          "app-name=Spotify" = {
            invisible = 1;
          };
        };
      };
    };
  };
}
