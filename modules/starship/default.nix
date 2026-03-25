{ config, lib, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.starship = {
    enable = lib.mkEnableOption "starship prompt";
  };

  config = lib.mkIf config.myConfig.modules.starship.enable {
    home-manager.users.${username} = {
      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          add_newline = false;

          format = lib.concatStrings [
            "$directory"
            # "$git_branch"
            # "$git_status"
            "$character"
          ];

          directory = {
            truncation_length = 0;
            truncate_to_repo = false;
          };

          username.disabled = true;
          hostname.disabled = true;
        };
      };
    };
  };
}
