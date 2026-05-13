{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.gjoa;
in
{
  options.myConfig.modules.gjoa.enable = lib.mkEnableOption "Gjoa — a Firefox fork. Wrapped via wrapFirefox; appears in launchers/drun.";
  options.myConfig.modules.gjoa.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set Gjoa as the default browser via MIME types";
  };
  imports = [ ./gjoa.nix ];
}
