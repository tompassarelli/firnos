{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.lutris.enable {
    environment.systemPackages = [ pkgs.lutris ];
  };
}
