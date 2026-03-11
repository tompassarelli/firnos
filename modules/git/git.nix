{ config, lib, ... }:
let
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf config.myConfig.git.enable {
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
            color-only = true;
            #syntax-theme = "DarkNeon"; # handled by stylix?
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
