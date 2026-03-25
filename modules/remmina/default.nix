{ lib, ... }:
{
  options.myConfig.modules.remmina = {
    enable = lib.mkEnableOption "Remmina remote desktop client";
  };

  imports = [
    ./remmina.nix
  ];
}
