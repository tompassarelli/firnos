{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.wine.enable = lib.mkEnableOption "Wine (unstable, 32+64-bit)";

  config = lib.mkIf config.myConfig.modules.wine.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.unstable
      winetricks
    ];
  };
}
