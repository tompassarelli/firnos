{ lib, ... }:
{
  options.myConfig.theme-switcher = {
    enable = lib.mkEnableOption "theme switcher script";
  };

  imports = [
    ./theme-switcher.nix
  ];
}
