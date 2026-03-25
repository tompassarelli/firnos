{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.nodejs.enable {
    environment.systemPackages = [ pkgs.nodejs ];
  };
}
