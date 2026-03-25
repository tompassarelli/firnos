{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.ffmpeg.enable = lib.mkEnableOption "FFmpeg video processing";

  config = lib.mkIf config.myConfig.modules.ffmpeg.enable {
    environment.systemPackages = [ pkgs.ffmpeg ];
  };
}
