{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.youtube-music.enable {
    environment.systemPackages = [ pkgs.youtube-music ];
  };
}
