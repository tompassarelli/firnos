{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.creative;
in
{
  options.myConfig.bundles.creative.enable = lib.mkEnableOption "creative tools and content creation";
  options.myConfig.bundles.creative.godot.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable godot";
  };
  options.myConfig.bundles.creative.blender.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable blender";
  };
  options.myConfig.bundles.creative.gimp.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable gimp";
  };
  options.myConfig.bundles.creative.obs-studio.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable obs-studio";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.godot.enable = lib.mkDefault cfg.godot.enable;
    myConfig.modules.blender.enable = lib.mkDefault cfg.blender.enable;
    myConfig.modules.gimp.enable = lib.mkDefault cfg.gimp.enable;
    myConfig.modules.obs-studio.enable = lib.mkDefault cfg.obs-studio.enable;
  };
}
