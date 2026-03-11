{ lib, ... }:
{
  options.myConfig.polkit = {
    enable = lib.mkEnableOption "Polkit security configuration";
  };

  imports = [
    ./polkit.nix
  ];
}
