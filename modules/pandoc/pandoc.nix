{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.pandoc.enable {
    environment.systemPackages = [ pkgs.pandoc ];
  };
}
