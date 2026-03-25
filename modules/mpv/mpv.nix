{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.mpv.enable {
    environment.systemPackages = [ pkgs.mpv ];
  };
}
