{ lib, ... }:
{
  options.myConfig.modules.fastfetch = {
    enable = lib.mkEnableOption "Enable fastfetch system info display";
  };

  imports = [
    ./fastfetch.nix
  ];
}
