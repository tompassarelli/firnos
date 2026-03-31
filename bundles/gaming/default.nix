{ config, lib, ... }:
let cfg = config.myConfig.bundles.gaming;
in {
  options.myConfig.bundles.gaming = {
    enable = lib.mkEnableOption "gaming platforms and tools";
    steam.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Steam"; };
    lutris.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Lutris"; };
    wowup.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable WowUp"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.steam.enable = lib.mkDefault cfg.steam.enable;
    myConfig.modules.lutris.enable = lib.mkDefault cfg.lutris.enable;
    myConfig.modules.wowup.enable = lib.mkDefault cfg.wowup.enable;
  };
}
