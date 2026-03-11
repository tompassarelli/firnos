{ config, lib, ... }:
let
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf config.myConfig.starship.enable {
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
