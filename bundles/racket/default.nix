{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.racket;
in
{
  options.myConfig.bundles.racket.enable = lib.mkEnableOption "Racket development";
  options.myConfig.bundles.racket.racket.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable racket";
  };
  options.myConfig.bundles.racket.drracket.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable drracket";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.racket.enable = lib.mkDefault cfg.racket.enable;
    myConfig.modules.drracket.enable = lib.mkDefault cfg.drracket.enable;
  };
}
