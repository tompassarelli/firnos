{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.networking;
in
{
  options.myConfig.modules.networking.enable = lib.mkEnableOption "network configuration";
  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    networking.networkmanager.unmanaged = [ "interface-name:wg*" ];
    networking.networkmanager.wifi.powersave = false;
    networking.networkmanager.logLevel = "DEBUG";
    environment.systemPackages = with pkgs; [ networkmanagerapplet ];
  };
}
