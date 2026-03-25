{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.remmina;
  username = config.myConfig.modules.users.username;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      remmina
    ];

    # Disable Remmina autostart by managing a hidden desktop file
    home-manager.users.${username} = {
      xdg.configFile."autostart/remmina-applet.desktop".text = ''
        [Desktop Entry]
        Hidden=true
      '';
    };
  };
}
