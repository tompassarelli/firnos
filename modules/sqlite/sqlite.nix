{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.sqlite.enable {
    environment.systemPackages = [ pkgs.sqlite ];
  };
}
