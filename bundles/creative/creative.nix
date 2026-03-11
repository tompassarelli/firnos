{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.creative;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.godot_4     # game engine and visual editor
      blender              # release your inner sculpter
      gimp                 # image editing for gimps
      obs-studio           # screen recording/streaming
      wf-recorder          # wayland screen recorder
      slurp                # wayland region selector
      ffmpeg               # video processing
      eyedropper           # modern wayland color picker
    ];
  };
}
