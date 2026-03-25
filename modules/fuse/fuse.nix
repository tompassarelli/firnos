{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.fuse.enable {
    environment.systemPackages = [ pkgs.fuse ];
  };
}
