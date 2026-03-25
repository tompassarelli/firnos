{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.blender.enable = lib.mkEnableOption "Blender 3D editor";

  config = lib.mkIf config.myConfig.modules.blender.enable {
    environment.systemPackages = [ pkgs.blender ];
  };
}
