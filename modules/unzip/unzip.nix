{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.unzip.enable {
    environment.systemPackages = [ pkgs.unzip ];
  };
}
