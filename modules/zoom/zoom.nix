{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.zoom.enable {
    environment.systemPackages = [ pkgs.zoom-us ];
  };
}
