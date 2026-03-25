{ lib, ... }:
{
  options.myConfig.blender.enable = lib.mkEnableOption "Blender 3D editor";
  imports = [ ./blender.nix ];
}
