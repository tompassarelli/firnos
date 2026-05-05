{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.vpn;
in
{
  options.myConfig.bundles.vpn.enable = lib.mkEnableOption "VPN support";
  options.myConfig.bundles.vpn.wireguard.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable wireguard";
  };
  options.myConfig.bundles.vpn.protonvpn-gui.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable protonvpn-gui";
  };
  options.myConfig.bundles.vpn.protonvpn-cli.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable protonvpn-cli";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.wireguard.enable = lib.mkDefault cfg.wireguard.enable;
    myConfig.modules.protonvpn-gui.enable = lib.mkDefault cfg.protonvpn-gui.enable;
    myConfig.modules.protonvpn-cli.enable = lib.mkDefault cfg.protonvpn-cli.enable;
  };
}
