{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.gh.enable {
    environment.systemPackages = [ pkgs.gh ];
  };
}
