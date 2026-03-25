{ config, lib, pkgs, flakeRoot, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  config = lib.mkIf config.myConfig.modules.awscli.enable {
    sops.secrets."aws-access-key-id" = {
      sopsFile = flakeRoot + "/secrets/aws.yaml";
      owner = username;
    };
    sops.secrets."aws-secret-access-key" = {
      sopsFile = flakeRoot + "/secrets/aws.yaml";
      owner = username;
    };

    environment.systemPackages = [ pkgs.awscli2 ];
  };
}
