{ lib, ... }:
{
  options.myConfig.modules.blender.enable = lib.mkEnableOption "Blender 3D editor";
  imports = [ ./blender.nix ];
}
