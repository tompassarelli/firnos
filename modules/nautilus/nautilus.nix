{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.nautilus.enable {
    environment.systemPackages = [ pkgs.nautilus ];
  };
}
