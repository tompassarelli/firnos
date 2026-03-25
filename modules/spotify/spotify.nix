{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.spotify.enable {
    environment.systemPackages = [ pkgs.spotify-player ];
  };
}
