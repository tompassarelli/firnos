{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.gh.enable {
    environment.systemPackages = [ pkgs.gh ];
  };
}
