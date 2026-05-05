{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.myConfig.modules.stylix.enable {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
