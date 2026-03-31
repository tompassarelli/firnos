{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.creative;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.godot.enable = lib.mkDefault cfg.godot.enable;
    myConfig.modules.blender.enable = lib.mkDefault cfg.blender.enable;
    myConfig.modules.gimp.enable = lib.mkDefault cfg.gimp.enable;
    myConfig.modules.obs-studio.enable = lib.mkDefault cfg.obs-studio.enable;
  };
}
