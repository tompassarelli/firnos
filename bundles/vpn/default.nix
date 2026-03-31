{ lib, ... }:
{
  options.myConfig.bundles.vpn = {
    enable = lib.mkEnableOption "VPN support";
    wireguard.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable WireGuard"; };
    protonvpn-gui.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ProtonVPN GUI"; };
    protonvpn-cli.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ProtonVPN CLI"; };
  };

  imports = [ ./vpn.nix ];
}
