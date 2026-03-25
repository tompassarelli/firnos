{ lib, ... }:
{
  options.myConfig.modules.ffmpeg.enable = lib.mkEnableOption "FFmpeg video processing";
  imports = [ ./ffmpeg.nix ];
}
