{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.nautilus.enable {
    environment.systemPackages = [ pkgs.nautilus ];
  };
}
