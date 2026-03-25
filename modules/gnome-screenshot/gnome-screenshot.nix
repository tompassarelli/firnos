{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.gnome-screenshot.enable {
    environment.systemPackages = [ pkgs.gnome-screenshot ];
  };
}
