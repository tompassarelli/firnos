{ lib, ... }:
{
  options.myConfig.fastfetch = {
    enable = lib.mkEnableOption "Enable fastfetch system info display";
  };

  imports = [
    ./fastfetch.nix
  ];
}
