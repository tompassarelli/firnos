{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.awscli.enable {
    environment.systemPackages = [ pkgs.awscli2 ];
  };
}
