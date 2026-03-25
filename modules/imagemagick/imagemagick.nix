{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.imagemagick.enable {
    environment.systemPackages = [ pkgs.imagemagick ];
  };
}
