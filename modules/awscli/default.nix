{ config, lib, pkgs, ... }:

let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.awscli.enable = lib.mkEnableOption "awscli";
  config = lib.mkIf config.myConfig.modules.awscli.enable {
    environment.systemPackages = with pkgs; [ awscli2 ];
  };
}
