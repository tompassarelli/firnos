{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.firefox;
in
{
  options.myConfig.modules.firefox.enable = lib.mkEnableOption "Enable Firefox browser";
  options.myConfig.modules.firefox.palefox.enable = lib.mkEnableOption "Enable Palefox (Firefox with custom UI styling)";
  options.myConfig.modules.firefox.default = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Set Firefox as the default browser via MIME types";
  };
  imports = [ ./firefox.nix ./palefox.nix ];
}
