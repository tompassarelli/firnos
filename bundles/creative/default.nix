{ config, lib, ... }:
let cfg = config.myConfig.bundles.creative;
in {
  options.myConfig.bundles.creative = {
    enable = lib.mkEnableOption "creative tools and content creation";
    godot.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Godot"; };
    blender.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Blender"; };
    gimp.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GIMP"; };
    obs-studio.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable OBS Studio"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.godot.enable = lib.mkDefault cfg.godot.enable;
    myConfig.modules.blender.enable = lib.mkDefault cfg.blender.enable;
    myConfig.modules.gimp.enable = lib.mkDefault cfg.gimp.enable;
    myConfig.modules.obs-studio.enable = lib.mkDefault cfg.obs-studio.enable;
  };
}
