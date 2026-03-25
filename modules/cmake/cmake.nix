{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.cmake.enable {
    environment.systemPackages = [ pkgs.cmake ];
  };
}
