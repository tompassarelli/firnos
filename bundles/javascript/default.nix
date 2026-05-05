{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.javascript;
in
{
  options.myConfig.bundles.javascript.enable = lib.mkEnableOption "JavaScript / Node.js development";
  options.myConfig.bundles.javascript.nodejs.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable nodejs";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.nodejs.enable = lib.mkDefault cfg.nodejs.enable;
  };
}
