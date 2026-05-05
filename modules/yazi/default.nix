{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.yazi;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.yazi.enable = lib.mkEnableOption "Yazi file manager";
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.yazi = {
        enable = true;
        settings = {
          opener = {
            edit = [
              {
                run = "nvim \"$@\"";
                block = true;
                for = "unix";
              }
            ];
          };
        };
      };
    };
  };
}
