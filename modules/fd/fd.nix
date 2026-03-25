{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.fd.enable {
    environment.systemPackages = [ pkgs.fd ];
  };
}
