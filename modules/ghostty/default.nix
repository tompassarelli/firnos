{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.ghostty;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.ghostty = {
        enable = true;
        package = pkgs.unstable.ghostty;
        settings = {
          window-padding-x = 6;
          window-padding-y = 4;
        };
      };
    };
  };
}
