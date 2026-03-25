{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.fwupd.enable {
    environment.systemPackages = [ pkgs.fwupd ];
  };
}
