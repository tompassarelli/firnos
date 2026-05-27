{ config, lib, flakeRoot, ... }:

let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.clockify.enable = lib.mkEnableOption "clockify";
  config = lib.mkIf config.myConfig.modules.clockify.enable {
    sops.secrets."msa-clockify-api-key" = {
      sopsFile = "${flakeRoot}/secrets/clockify.yaml";
      owner = username;
    };
  };
}
