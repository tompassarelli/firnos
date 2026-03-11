{ lib, ... }:
{
  options.myConfig.protonvpn = {
    enable = lib.mkEnableOption "ProtonVPN client";
  };

  imports = [
    ./protonvpn.nix
  ];
}
