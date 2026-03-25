{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.auth;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.polkit.enable = lib.mkDefault cfg.polkit.enable;
    myConfig.modules.gnome-keyring.enable = lib.mkDefault cfg.gnome-keyring.enable;
  };
}
