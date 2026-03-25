{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.obs-studio.enable {
    environment.systemPackages = [ pkgs.obs-studio ];
  };
}
