{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.protonvpn-gui.enable {
    environment.systemPackages = [ pkgs.protonvpn-gui ];
  };
}
