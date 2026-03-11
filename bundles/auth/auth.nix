{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.auth.enable {
    myConfig.polkit.enable = lib.mkDefault true;
    myConfig.gnome-keyring.enable = lib.mkDefault true;
  };
}
