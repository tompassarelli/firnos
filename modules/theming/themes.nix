{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.theming.enable {
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme   # default GNOME icons (needed for nautilus)
      gnome-themes-extra   # includes Adwaita-dark theme
    ];
  };
}
