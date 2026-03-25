{ lib, ... }:
{
  options.myConfig.modules.yazi = {
    enable = lib.mkEnableOption "Yazi file manager";
  };

  imports = [
    ./yazi.nix
  ];
}
