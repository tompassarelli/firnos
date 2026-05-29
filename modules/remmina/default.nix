{ config, lib, pkgs, ... }:

let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.remmina.enable = lib.mkEnableOption "Remmina remote desktop client";
  config = lib.mkIf config.myConfig.modules.remmina.enable {
    environment.systemPackages = with pkgs; [ remmina ];
    home-manager.users.${username} = {
      xdg.configFile."autostart/remmina-applet.desktop".text = ''
        [Desktop Entry]
        Hidden=true

      '';
    };
  };
}
