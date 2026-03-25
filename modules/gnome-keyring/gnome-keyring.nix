{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.modules.gnome-keyring.enable {
    security.pam.services.login.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
  };
}
