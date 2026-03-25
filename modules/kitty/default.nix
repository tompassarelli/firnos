{ lib, ... }:
{
  options.myConfig.modules.kitty = {
    enable = lib.mkEnableOption "Kitty terminal configuration";
  };

  imports = [
    ./kitty.nix
  ];
}
