{ config, lib, ... }:
let cfg = config.myConfig.bundles.javascript;
in {
  options.myConfig.bundles.javascript = {
    enable = lib.mkEnableOption "JavaScript / Node.js development";
    nodejs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Node.js"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.nodejs.enable = lib.mkDefault cfg.nodejs.enable;
  };
}
