{ config, lib, pkgs, flakeRoot, ... }:

let
  cfg = config.myConfig.modules.awscli;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.awscli.enable = lib.mkEnableOption "awscli";
  config = lib.mkIf cfg.enable {
    sops.secrets."aws-access-key-id" = {
      sopsFile = flakeRoot + "/secrets/aws.yaml";
      owner = username;
    };
    sops.secrets."aws-secret-access-key" = {
      sopsFile = flakeRoot + "/secrets/aws.yaml";
      owner = username;
    };
    sops.templates."aws-credentials" = {
      content = ''
        [default]
        aws_access_key_id = ${config.sops.placeholder."aws-access-key-id"}
        aws_secret_access_key = ${config.sops.placeholder."aws-secret-access-key"}
      '';
      owner = username;
      path = "/home/${username}/.aws/credentials";
    };
    sops.templates."aws-config" = {
      content = ''
        [default]
        region = us-east-2
        output = json
      '';
      owner = username;
      path = "/home/${username}/.aws/config";
    };
    environment.systemPackages = with pkgs; [ awscli2 ];
  };
}
