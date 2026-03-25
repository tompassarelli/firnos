{ lib, ... }:
{
  options.myConfig.modules.starship = {
    enable = lib.mkEnableOption "starship prompt";
  };

  imports = [
    ./starship.nix
  ];
}
