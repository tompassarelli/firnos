{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.piper.enable {
    # ratbagd daemon for configuring gaming mice
    services.ratbagd.enable = true;

    # Piper - GTK GUI for ratbagd
    environment.systemPackages = [ pkgs.piper ];
  };
}
