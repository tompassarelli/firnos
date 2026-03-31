{ config, lib, ... }:
let cfg = config.myConfig.bundles.vpn;
in {
  options.myConfig.bundles.vpn = {
    enable = lib.mkEnableOption "VPN support";
    wireguard.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable WireGuard"; };
    protonvpn-gui.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ProtonVPN GUI"; };
    protonvpn-cli.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ProtonVPN CLI"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.wireguard.enable = lib.mkDefault cfg.wireguard.enable;
    myConfig.modules.protonvpn-gui.enable = lib.mkDefault cfg.protonvpn-gui.enable;
    myConfig.modules.protonvpn-cli.enable = lib.mkDefault cfg.protonvpn-cli.enable;
  };
}
