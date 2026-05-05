{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.glide;
in
{
  options.myConfig.modules.glide.enable = lib.mkEnableOption "Glide touchpad motion detection daemon";
  options.myConfig.modules.glide.device = lib.mkOption {
    type = lib.types.str;
    default = "/dev/input/by-path/platform-AMDI0010:03-event-mouse";
    description = "Touchpad evdev device path";
  };
  options.myConfig.modules.glide.kanataAddress = lib.mkOption {
    type = lib.types.str;
    default = "127.0.0.1:7070";
    description = "Kanata TCP server address (ip:port)";
  };
  options.myConfig.modules.glide.virtualKey = lib.mkOption {
    type = lib.types.str;
    default = "pad-touch";
    description = "Kanata virtual key name to press/release on activation";
  };
  options.myConfig.modules.glide.motionThreshold = lib.mkOption {
    type = lib.types.int;
    default = 2;
    description = "Min Euclidean displacement (device abs units) per evdev report to count as motion";
  };
  options.myConfig.modules.glide.minStreak = lib.mkOption {
    type = lib.types.int;
    default = 16;
    description = "Consecutive motion-positive samples required to activate (~7ms each, 16 ≈ 112ms)";
  };
  imports = [ ./glide.nix ];
}
