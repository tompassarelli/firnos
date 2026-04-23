{ config, lib, ... }:
let cfg = config.myConfig.bundles.racket;
in {
  options.myConfig.bundles.racket = {
    enable = lib.mkEnableOption "Racket development";
    racket.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Racket"; };
    drracket.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable DrRacket"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.racket.enable = lib.mkDefault cfg.racket.enable;
    myConfig.modules.drracket.enable = lib.mkDefault cfg.drracket.enable;
  };
}
