{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.protonvpn-cli.enable = lib.mkEnableOption "ProtonVPN CLI client";

  config = lib.mkIf config.myConfig.modules.protonvpn-cli.enable {
    environment.systemPackages = [ pkgs.protonvpn-cli ];
  };
}
