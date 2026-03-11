{ lib, ... }:
{
  options.myConfig.productivity = {
    enable = lib.mkEnableOption "personal productivity applications";
  };

  imports = [
    ./productivity.nix
  ];
}