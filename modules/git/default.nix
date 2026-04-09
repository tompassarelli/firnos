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
        settings = {
          user.name = "tompassarelli";
          user.email = "tom.passarelli@protonmail.com";
          init.defaultBranch = "main";
          core.editor = "nvim";
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";
        };
      };
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          navigate = true;
        };
      };
    };
  };
}
