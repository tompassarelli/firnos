{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.imagemagick.enable {
    environment.systemPackages = [
      pkgs.imagemagick
      pkgs.ghostscript
    ];
  };
}
