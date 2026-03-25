{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.discord.enable = lib.mkEnableOption "Discord chat client";

  config = lib.mkIf config.myConfig.modules.discord.enable {
    environment.systemPackages = [ pkgs.discord ];
  };
}
