{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.ffmpeg.enable {
    environment.systemPackages = [ pkgs.ffmpeg ];
  };
}
