{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.librewolf;
in
{
  options.myConfig.modules.librewolf.enable = lib.mkEnableOption "Enable LibreWolf browser";
  options.myConfig.modules.librewolf.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set LibreWolf as the default browser via MIME types";
  };
  imports = [ ./librewolf.nix ];
}
