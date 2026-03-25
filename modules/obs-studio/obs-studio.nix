{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.obs-studio.enable {
    environment.systemPackages = [ pkgs.obs-studio ];
  };
}
