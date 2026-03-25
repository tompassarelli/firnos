{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.nodejs.enable {
    environment.systemPackages = [ pkgs.nodejs ];
  };
}
