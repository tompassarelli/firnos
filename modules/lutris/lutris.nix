{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.lutris.enable {
    environment.systemPackages = [ pkgs.lutris ];
  };
}
