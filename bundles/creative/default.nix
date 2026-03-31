{ lib, ... }:
{
  options.myConfig.bundles.creative = {
    enable = lib.mkEnableOption "creative tools and content creation";
    godot.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Godot"; };
    blender.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Blender"; };
    gimp.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GIMP"; };
    obs-studio.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable OBS Studio"; };
  };

  imports = [
    ./creative.nix
  ];
}
