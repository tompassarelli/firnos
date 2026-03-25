{ lib, ... }:
{
  options.myConfig.creative = {
    enable = lib.mkEnableOption "creative tools and content creation";
    godot.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Godot"; };
    blender.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Blender"; };
    gimp.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GIMP"; };
    obs-studio.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable OBS Studio"; };
    wf-recorder.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable wf-recorder"; };
    slurp.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable slurp"; };
    ffmpeg.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable FFmpeg"; };
    eyedropper.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Eyedropper"; };
  };

  imports = [
    ./creative.nix
  ];
}
