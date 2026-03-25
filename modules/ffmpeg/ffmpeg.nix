{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.ffmpeg.enable {
    environment.systemPackages = [ pkgs.ffmpeg ];
  };
}
