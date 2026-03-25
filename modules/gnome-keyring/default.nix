{ config, lib, ... }:
{
  options.myConfig.modules.gnome-keyring = {
    enable = lib.mkEnableOption "GNOME Keyring (secrets storage + Seahorse GUI)";
  };

  config = lib.mkIf config.myConfig.modules.gnome-keyring.enable {
    security.pam.services.login.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
  };
}
