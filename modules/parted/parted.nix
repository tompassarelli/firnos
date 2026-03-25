{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.parted.enable {
    environment.systemPackages = [ pkgs.parted ];
  };
}
