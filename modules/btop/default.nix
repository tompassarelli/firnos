{ lib, ... }:
{
  options.myConfig.modules.btop = {
    enable = lib.mkEnableOption "Enable btop system monitor";
  };

  imports = [
    ./btop.nix
  ];
}
