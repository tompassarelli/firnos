{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.brightnessctl = {
    enable = lib.mkEnableOption "screen brightness control";
  };

  config = lib.mkIf config.myConfig.modules.brightnessctl.enable {
    environment.systemPackages = [ pkgs.brightnessctl ];
  };
}
