{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.bluetooth;
in
{
  options.myConfig.modules.bluetooth.enable = lib.mkEnableOption "Enable Bluetooth configuration";
  config = lib.mkIf cfg.enable {
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
    services.blueman.enable = true;
    environment.systemPackages = with pkgs; [ bluez ];
  };
}
