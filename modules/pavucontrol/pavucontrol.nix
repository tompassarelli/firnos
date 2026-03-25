{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.pavucontrol.enable {
    environment.systemPackages = [ pkgs.pavucontrol ];
  };
}
