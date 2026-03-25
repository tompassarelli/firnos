{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.zoom.enable {
    environment.systemPackages = [ pkgs.zoom-us ];
  };
}
