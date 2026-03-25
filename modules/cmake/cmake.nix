{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.cmake.enable {
    environment.systemPackages = [ pkgs.cmake ];
  };
}
