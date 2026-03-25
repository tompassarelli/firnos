{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.gnumake.enable {
    environment.systemPackages = [ pkgs.gnumake ];
  };
}
