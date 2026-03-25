{ config, lib, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.git = {
    enable = lib.mkEnableOption "Git configuration";
  };

  config = lib.mkIf config.myConfig.modules.git.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============
    # (None needed - git is installed via home-manager)

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = {
      programs.git = {
        enable = true;
        userName = "tompassarelli";
        userEmail = "tom.passarelli@protonmail.com";
        delta = {
          enable = true;
          options = {
            navigate = true;
          };
        };
        extraConfig = {
          init.defaultBranch = "main";
          core.editor = "nvim";
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";
        };
      };
    };
  };
}
