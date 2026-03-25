{ lib, ... }:
{
  options.myConfig.ffmpeg.enable = lib.mkEnableOption "FFmpeg video processing";
  imports = [ ./ffmpeg.nix ];
}
