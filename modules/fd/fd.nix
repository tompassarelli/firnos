{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.fd.enable {
    environment.systemPackages = [ pkgs.fd ];
  };
}
