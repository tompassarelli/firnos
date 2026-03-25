{ config, lib, ... }:

let
  cfg = config.myConfig.creative;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.godot.enable = lib.mkDefault cfg.godot.enable;
    myConfig.blender.enable = lib.mkDefault cfg.blender.enable;
    myConfig.gimp.enable = lib.mkDefault cfg.gimp.enable;
    myConfig.obs-studio.enable = lib.mkDefault cfg.obs-studio.enable;
    myConfig.wf-recorder.enable = lib.mkDefault cfg.wf-recorder.enable;
    myConfig.slurp.enable = lib.mkDefault cfg.slurp.enable;
    myConfig.ffmpeg.enable = lib.mkDefault cfg.ffmpeg.enable;
    myConfig.eyedropper.enable = lib.mkDefault cfg.eyedropper.enable;
  };
}
