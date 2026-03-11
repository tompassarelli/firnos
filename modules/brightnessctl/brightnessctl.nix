{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.brightnessctl.enable {
    environment.systemPackages = with pkgs; [
      brightnessctl
      libnotify
    ];
  };
}
