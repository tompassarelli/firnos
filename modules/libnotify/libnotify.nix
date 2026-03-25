{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.libnotify.enable {
    environment.systemPackages = [ pkgs.libnotify ];
  };
}
