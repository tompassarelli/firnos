{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.swaylock.enable {
    environment.systemPackages = [ pkgs.swaylock ];
  };
}
