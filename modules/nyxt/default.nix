{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.nyxt;
in
{
  options.myConfig.modules.nyxt.enable = lib.mkEnableOption "Enable Nyxt browser";
  options.myConfig.modules.nyxt.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set Nyxt as the default browser via MIME types";
  };
  imports = [ ./nyxt.nix ];
}
