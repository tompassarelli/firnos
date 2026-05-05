{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.auth;
in
{
  options.myConfig.bundles.auth.enable = lib.mkEnableOption "authentication (polkit + GNOME Keyring)";
  options.myConfig.bundles.auth.polkit.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable polkit";
  };
  options.myConfig.bundles.auth.gnome-keyring.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable gnome-keyring";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.polkit.enable = lib.mkDefault cfg.polkit.enable;
    myConfig.modules.gnome-keyring.enable = lib.mkDefault cfg.gnome-keyring.enable;
  };
}
