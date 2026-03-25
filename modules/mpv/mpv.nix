{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.mpv.enable {
    environment.systemPackages = [ pkgs.mpv ];
  };
}
