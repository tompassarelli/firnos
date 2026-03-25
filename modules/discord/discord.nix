{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.discord.enable {
    environment.systemPackages = [ pkgs.discord ];
  };
}
