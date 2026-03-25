{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.hugo.enable {
    environment.systemPackages = [ pkgs.hugo ];
  };
}
