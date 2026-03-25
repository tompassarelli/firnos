{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.pavucontrol.enable {
    environment.systemPackages = [ pkgs.pavucontrol ];
  };
}
