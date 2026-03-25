{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.imv.enable {
    environment.systemPackages = [ pkgs.imv ];
  };
}
