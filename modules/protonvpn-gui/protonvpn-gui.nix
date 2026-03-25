{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.protonvpn-gui.enable {
    environment.systemPackages = [ pkgs.protonvpn-gui ];
  };
}
