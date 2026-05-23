{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.qutebrowser.enable = lib.mkEnableOption "Enable Qutebrowser";
  options.myConfig.modules.qutebrowser.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set Qutebrowser as the default browser via MIME types";
  };
  imports = [ ./qutebrowser.nix ];
}
