{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.myConfig.modules.stylix.enable {
    environment.systemPackages = with pkgs; [ adwaita-icon-theme gnome-themes-extra ];
  };
}
