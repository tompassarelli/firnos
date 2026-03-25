{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.protonvpn-cli.enable {
    environment.systemPackages = [ pkgs.protonvpn-cli ];
  };
}
