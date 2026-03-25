{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.youtube-music.enable {
    environment.systemPackages = [ pkgs.youtube-music ];
  };
}
