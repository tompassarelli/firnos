{ lib, ... }:
{
  options.myConfig.ladybird = {
    enable = lib.mkEnableOption "Enable Ladybird browser (bleeding edge from git)";
  };

  imports = [
    ./ladybird.nix
  ];
}
