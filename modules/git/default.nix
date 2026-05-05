{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.git;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.git.enable = lib.mkEnableOption "Git configuration";
  config = lib.mkIf cfg.enable {
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
