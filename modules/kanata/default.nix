{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.kanata;
in
{
  options.myConfig.modules.kanata.enable = lib.mkEnableOption "Kanata keyboard remapping";
  options.myConfig.modules.kanata.devices = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Input device paths for kanata to capture. Find yours with: ls /dev/input/by-id/";
  };
  options.myConfig.modules.kanata.configFile = lib.mkOption {
    type = lib.types.path;
    description = "Path to kanata .kbd config file";
  };
  options.myConfig.modules.kanata.port = lib.mkOption {
    type = lib.types.nullOr lib.types.port;
    default = null;
    description = "TCP port for kanata server (e.g. for glide integration)";
  };
  imports = [ ./kanata.nix ];
}
