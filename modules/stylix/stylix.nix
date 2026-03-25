{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.stylix.enable {
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme   # default GNOME icons (needed for nautilus)
      gnome-themes-extra   # includes Adwaita-dark theme
    ];
  };
}
