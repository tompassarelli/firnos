{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.vpn;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.wireguard.enable = lib.mkDefault cfg.wireguard.enable;
    myConfig.modules.protonvpn-gui.enable = lib.mkDefault cfg.protonvpn-gui.enable;
    myConfig.modules.protonvpn-cli.enable = lib.mkDefault cfg.protonvpn-cli.enable;
  };
}
