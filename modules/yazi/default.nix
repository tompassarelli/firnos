{ config, lib, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.yazi = {
    enable = lib.mkEnableOption "Yazi file manager";
  };

  config = lib.mkIf config.myConfig.modules.yazi.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============
    # (None needed - yazi is installed via home-manager)

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = {
      programs.yazi = {
        enable = true;
        settings = {
          opener = {
            edit = [
              { run = "nvim \"$@\""; block = true; for = "unix"; }
            ];
          };
        };
      };
    };
  };
}
