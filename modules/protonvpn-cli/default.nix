{ lib, ... }:
{
  options.myConfig.protonvpn-cli.enable = lib.mkEnableOption "ProtonVPN CLI client";
  imports = [ ./protonvpn-cli.nix ];
}
