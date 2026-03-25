{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth configuration";
  };

  config = lib.mkIf config.myConfig.modules.bluetooth.enable {
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
