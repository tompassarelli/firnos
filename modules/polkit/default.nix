{ lib, ... }:
{
  options.myConfig.modules.polkit = {
    enable = lib.mkEnableOption "Polkit security configuration";
  };

  imports = [
    ./polkit.nix
  ];
}
