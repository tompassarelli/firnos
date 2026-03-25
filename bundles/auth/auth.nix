{ config, lib, ... }:

let
  cfg = config.myConfig.auth;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.polkit.enable = lib.mkDefault cfg.polkit.enable;
    myConfig.gnome-keyring.enable = lib.mkDefault cfg.gnome-keyring.enable;
  };
}
