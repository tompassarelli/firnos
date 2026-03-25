{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.imv.enable {
    environment.systemPackages = [ pkgs.imv ];
  };
}
