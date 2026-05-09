{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.wine;
in
{
  options.myConfig.modules.wine.enable = lib.mkEnableOption "Wine (unstable, 32+64-bit)";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ wineWowPackages.unstable unstable.winetricks ];
  };
}
