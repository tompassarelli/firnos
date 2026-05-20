{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.awscli;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.awscli.enable = lib.mkEnableOption "awscli";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ awscli2 ];
  };
}
