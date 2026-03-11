{ lib, ... }:
{
  options.myConfig.kitty = {
    enable = lib.mkEnableOption "Kitty terminal configuration";
  };

  imports = [
    ./kitty.nix
  ];
}
