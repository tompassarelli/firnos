{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.glide;
in
{
  options.myConfig.glide = {
    enable = lib.mkEnableOption "Glide touchpad motion detection daemon";

    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/input/by-path/platform-AMDI0010:03-event-mouse";
      description = "Touchpad evdev device path";
    };

    kanataAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:7070";
      description = "Kanata TCP server address (ip:port)";
    };

    virtualKey = lib.mkOption {
      type = lib.types.str;
      default = "pad-touch";
      description = "Kanata virtual key name to press/release on activation";
    };

    motionThreshold = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Min Euclidean displacement (device abs units) per evdev report to count as motion";
    };

    minStreak = lib.mkOption {
      type = lib.types.int;
      default = 16;
      description = "Consecutive motion-positive samples required to activate (~7ms each, 16 ≈ 112ms)";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.glide = {
      description = "Glide touchpad motion detection daemon";
      after = [ "kanata-main.service" ];
      wants = [ "kanata-main.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.glide}/bin/glide"
          "--device" cfg.device
          "--kanata-address" cfg.kanataAddress
          "--virtual-key" cfg.virtualKey
          "--motion-threshold" (toString cfg.motionThreshold)
          "--min-streak" (toString cfg.minStreak)
        ];
        Restart = "on-failure";
        RestartSec = 2;

        # Needs access to input devices
        SupplementaryGroups = [ "input" ];
      };
    };
  };
}
