{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.bluetooth.enable {
    # Enable Bluetooth hardware support
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    # Enable Blueman for GUI management
    services.blueman.enable = true;

    # Make sure bluetooth is available to user session
    environment.systemPackages = with pkgs; [
      bluez
    ];
  };
}
