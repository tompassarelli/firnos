{ lib, ... }:
{
  options.myConfig.modules.theme-switcher = {
    enable = lib.mkEnableOption "theme switcher script";
  };

  imports = [
    ./theme-switcher.nix
  ];
}
