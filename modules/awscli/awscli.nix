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

    # Generate ~/.aws/credentials from decrypted sops secrets
    sops.templates."aws-credentials" = {
      content = ''
        [default]
        aws_access_key_id = ${config.sops.placeholder."aws-access-key-id"}
        aws_secret_access_key = ${config.sops.placeholder."aws-secret-access-key"}
      '';
      owner = username;
      path = "/home/${username}/.aws/credentials";
    };

    # Default region/output (same dir as credentials, so use sops.templates to avoid permission conflict)
    sops.templates."aws-config" = {
      content = ''
        [default]
        region = us-east-2
        output = json
      '';
      owner = username;
      path = "/home/${username}/.aws/config";
    };

    environment.systemPackages = [ pkgs.awscli2 ];
  };
}
