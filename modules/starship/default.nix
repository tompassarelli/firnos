{ lib, ... }:
{
  options.myConfig.starship = {
    enable = lib.mkEnableOption "starship prompt";
  };

  imports = [
    ./starship.nix
  ];
}
