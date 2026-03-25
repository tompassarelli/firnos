{ lib, ... }:
{
  options.myConfig.protonvpn-gui.enable = lib.mkEnableOption "ProtonVPN GUI client";
  imports = [ ./protonvpn-gui.nix ];
}
