{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.delta.enable {
    environment.systemPackages = [ pkgs.delta ];
  };
}
