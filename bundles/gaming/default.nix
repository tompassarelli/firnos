{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.gaming;
in
{
  options.myConfig.bundles.gaming.enable = lib.mkEnableOption "gaming platforms and tools";
  options.myConfig.bundles.gaming.steam.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable steam";
  };
  options.myConfig.bundles.gaming.lutris.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable lutris";
  };
  options.myConfig.bundles.gaming.wowup.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable wowup";
  };
  options.myConfig.bundles.gaming.wine.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable wine";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.steam.enable = lib.mkDefault cfg.steam.enable;
    myConfig.modules.lutris.enable = lib.mkDefault cfg.lutris.enable;
    myConfig.modules.wowup.enable = lib.mkDefault cfg.wowup.enable;
    myConfig.modules.wine.enable = lib.mkDefault cfg.wine.enable;
  };
}
