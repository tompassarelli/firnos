{ lib, ... }:
{
  options.myConfig.wireguard = {
    enable = lib.mkEnableOption "WireGuard VPN support";
  };

  imports = [
    ./wireguard.nix
  ];
}
