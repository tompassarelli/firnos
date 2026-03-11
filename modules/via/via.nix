{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.via;
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf cfg.enable {
    # Udev rules for VIA to access keyboards
    # Based on official VIA udev rules: https://github.com/the-via/releases/releases/latest
    services.udev.extraRules = ''
      # VIA keyboard access rules
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", TAG+="uaccess"

      # Additional rules for QMK/VIA keyboards
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="c2ab", ATTRS{idProduct}=="3939", TAG+="uaccess"
    '';

    # Ensure plugdev group exists
    users.groups.plugdev = {};

    # Add your user to plugdev group
    users.users.${username}.extraGroups = [ "plugdev" ];
  };
}
