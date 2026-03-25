{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.protonvpn-cli.enable {
    environment.systemPackages = [ pkgs.protonvpn-cli ];
  };
}
