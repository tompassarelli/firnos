{ lib, ... }:
{
  options.myConfig.modules.wireguard = {
    enable = lib.mkEnableOption "WireGuard VPN support";
  };

  imports = [
    ./wireguard.nix
  ];
}
