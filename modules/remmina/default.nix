{ lib, ... }:
{
  options.myConfig.remmina = {
    enable = lib.mkEnableOption "Remmina remote desktop client";
  };

  imports = [
    ./remmina.nix
  ];
}
