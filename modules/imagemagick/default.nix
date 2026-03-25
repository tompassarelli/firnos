{ lib, ... }:
{
  options.myConfig.imagemagick.enable = lib.mkEnableOption "ImageMagick image processing";
  imports = [ ./imagemagick.nix ];
}
