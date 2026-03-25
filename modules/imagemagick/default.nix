{ lib, ... }:
{
  options.myConfig.modules.imagemagick.enable = lib.mkEnableOption "ImageMagick image processing";
  imports = [ ./imagemagick.nix ];
}
