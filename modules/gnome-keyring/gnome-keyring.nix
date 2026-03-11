{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.gnome-keyring.enable {
    security.pam.services.login.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
  };
}
