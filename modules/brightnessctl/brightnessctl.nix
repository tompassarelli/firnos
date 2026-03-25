{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.brightnessctl.enable {
    environment.systemPackages = [ pkgs.brightnessctl ];
  };
}
