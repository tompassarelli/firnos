{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.unrar.enable {
    environment.systemPackages = [ pkgs.unrar ];
  };
}
