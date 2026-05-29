{ config, lib, pkgs, flakeRoot, ... }:

let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.awscli.enable = lib.mkEnableOption "awscli";
  config = lib.mkIf config.myConfig.modules.awscli.enable {
    environment.systemPackages = [ pkgs.awscli2 ];
    sops.secrets = {
      "aws-access-key-id" = {
        sopsFile = "${flakeRoot}/secrets/aws.yaml";
        owner = username;
      };
      "aws-secret-access-key" = {
        sopsFile = "${flakeRoot}/secrets/aws.yaml";
        owner = username;
      };
    };
    sops.templates = {
      "aws-credentials" = {
        content = ''
          [default]
          aws_access_key_id = ${config.sops.placeholder.aws-access-key-id}
          aws_secret_access_key = ${config.sops.placeholder.aws-secret-access-key}

        '';
        owner = username;
      };
      "aws-config" = {
        content = ''
          [default]
          region = us-east-2
          output = json

        '';
        owner = username;
      };
    };
  };
}
