{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.gnome-screenshot.enable = lib.mkEnableOption "GNOME Screenshot tool";
  config = lib.mkIf config.myConfig.modules.gnome-screenshot.enable {
    environment.systemPackages = with pkgs; [ gnome-screenshot ];
  };
}
