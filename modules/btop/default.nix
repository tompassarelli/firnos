{ lib, ... }:
{
  options.myConfig.btop = {
    enable = lib.mkEnableOption "Enable btop system monitor";
  };

  imports = [
    ./btop.nix
  ];
}
