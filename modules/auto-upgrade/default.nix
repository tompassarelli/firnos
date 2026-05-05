{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.auto-upgrade;
in
{
  options.myConfig.modules.auto-upgrade.enable = lib.mkEnableOption "Automatic system updates";
  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      flake = "/home/tom/code/nixos-config";
      flags = [ "--update-input" "nixpkgs" "--update-input" "nixpkgs-unstable" "--commit-lock-file" ];
      dates = "Sun 03:00";
      randomizedDelaySec = "30min";
      allowReboot = false;
    };
  };
}
