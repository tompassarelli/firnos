{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.discord.enable {
    environment.systemPackages = [ pkgs.discord ];
  };
}
