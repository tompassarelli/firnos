{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.gnome-screenshot.enable {
    environment.systemPackages = [ pkgs.gnome-screenshot ];
  };
}
