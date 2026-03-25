{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.libtool.enable {
    environment.systemPackages = [ pkgs.libtool ];
  };
}
