{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.libtool.enable {
    environment.systemPackages = [ pkgs.libtool ];
  };
}
