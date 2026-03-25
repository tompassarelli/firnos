{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.gaming;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.steam.enable = lib.mkDefault cfg.steam.enable;
    myConfig.modules.lutris.enable = lib.mkDefault cfg.lutris.enable;
    myConfig.modules.wowup.enable = lib.mkDefault cfg.wowup.enable;
  };
}
