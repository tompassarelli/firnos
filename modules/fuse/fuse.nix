{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.fuse.enable {
    environment.systemPackages = [ pkgs.fuse ];
  };
}
