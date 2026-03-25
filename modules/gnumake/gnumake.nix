{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.gnumake.enable {
    environment.systemPackages = [ pkgs.gnumake ];
  };
}
