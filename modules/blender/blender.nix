{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.blender.enable {
    environment.systemPackages = [ pkgs.blender ];
  };
}
