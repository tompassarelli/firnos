{ lib, ... }:
{
  options.myConfig.yazi = {
    enable = lib.mkEnableOption "Yazi file manager";
  };

  imports = [
    ./yazi.nix
  ];
}
