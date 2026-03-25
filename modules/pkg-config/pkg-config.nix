{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.pkg-config.enable {
    environment.systemPackages = [ pkgs.pkg-config ];
  };
}
