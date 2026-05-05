{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.chrome;
in
{
  options.myConfig.modules.chrome.enable = lib.mkEnableOption "Enable Google Chrome browser";
  options.myConfig.modules.chrome.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set Chrome as the default browser via MIME types";
  };
  imports = [ ./chrome.nix ];
}
