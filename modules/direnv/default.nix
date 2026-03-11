{ lib, ... }:
{
  options.myConfig.direnv = {
    enable = lib.mkEnableOption "direnv for automatic dev shell activation";
  };

  imports = [
    ./direnv.nix
  ];
}
