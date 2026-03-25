{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.blender.enable {
    environment.systemPackages = [ pkgs.blender ];
  };
}
