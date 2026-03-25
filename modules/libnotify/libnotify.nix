{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.libnotify.enable {
    environment.systemPackages = [ pkgs.libnotify ];
  };
}
