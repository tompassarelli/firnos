{ config, lib, ... }:
let
  cfg = config.myConfig.modules.auto-upgrade;
in
{
  options.myConfig.modules.auto-upgrade = {
    enable = lib.mkEnableOption "Automatic system updates";
  };

  config = lib.mkIf cfg.enable {
    # Automatic system upgrades
    system.autoUpgrade = {
      enable = true;
      flake = "/home/tom/code/nixos-config";
      flags = [
        "--update-input" "nixpkgs"
        "--update-input" "nixpkgs-unstable"
        "--commit-lock-file"
      ];
      dates = "Sun 03:00";
      randomizedDelaySec = "30min";  # Random delay up to 30min to avoid exact 3am every time
      allowReboot = false;  # Don't auto-reboot, just apply updates that don't need reboots
    };
  };
}
