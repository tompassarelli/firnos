{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.eza.enable {
    environment.systemPackages = with pkgs; [ eza ];
  };
}
