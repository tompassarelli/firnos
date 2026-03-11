{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.piper.enable {
    # ratbagd daemon for configuring gaming mice (Logitech G102/G203, etc.)
    services.ratbagd.enable = true;

    # Piper - GTK GUI for ratbagd
    # g203-led - dedicated LED control for G102/G203 mice
    environment.systemPackages = [
      pkgs.piper
      pkgs.g203-led
    ];

    # Turn off G102/G203 Lightsync LED on connect
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c092", RUN+="${pkgs.g203-led}/bin/g203-led lightsync solid 000000"
    '';
  };
}
