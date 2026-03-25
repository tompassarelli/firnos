{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.imagemagick.enable = lib.mkEnableOption "ImageMagick image processing";

  config = lib.mkIf config.myConfig.modules.imagemagick.enable {
    environment.systemPackages = [ pkgs.imagemagick ];
  };
}
