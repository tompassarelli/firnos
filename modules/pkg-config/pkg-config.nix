{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.pkg-config.enable {
    environment.systemPackages = [ pkgs.pkg-config ];
  };
}
