{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.g203-led.enable {
    environment.systemPackages = [ pkgs.g203-led ];

    # Turn off G102/G203 Lightsync LED on connect
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c092", RUN+="${pkgs.g203-led}/bin/g203-led lightsync solid 000000"
    '';
  };
}
