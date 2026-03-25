{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.eza.enable {
    environment.systemPackages = with pkgs; [ eza ];
  };
}
