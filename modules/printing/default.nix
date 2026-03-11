{ lib, ... }:
{
  options.myConfig.printing = {
    enable = lib.mkEnableOption "Enable printing with CUPS";
  };

  imports = [
    ./printing.nix
  ];
}
